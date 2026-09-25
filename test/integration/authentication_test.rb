require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  def authenticate_for_test?
    false
  end

  test "calendar, clients, settings, and availability require authentication" do
    [ root_path, clients_path, stylists_path, services_path, availability_appointments_path ].each do |path|
      get path
      assert_redirected_to login_path
    end
    assert_no_difference "Client.count" do
      post clients_path, params: { client: { name: "Unauthorized" } }
    end
    assert_redirected_to login_path
    get rails_health_check_path
    assert_response :success
  end

  test "sign in normalizes username, returns to requested page, and signs out" do
    get clients_path(q: "Morgan")
    post login_path, params: { username: " ADMIN ", password: "studio-test-password" }
    assert_redirected_to clients_path(q: "Morgan")
    follow_redirect!
    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_select "button", text: "Sign out"
    delete logout_path
    assert_redirected_to login_path
    get clients_path
    assert_redirected_to login_path
  end

  test "wrong username and password show the same message and keep password empty" do
    [ [ "admin", "wrong" ], [ "unknown", "studio-test-password" ], [ "admin", "" ] ].each do |username, password|
      post login_path, params: { username: username, password: password }
      assert_response :unprocessable_entity
      assert_select "[role=alert]", text: /username or password wasn’t quite right/
      assert_select "input[type=password][value]", count: 0
      get root_path
      assert_redirected_to login_path
    end
  end

  test "session expires after twelve hours" do
    post login_path, params: { username: "admin", password: "studio-test-password" }
    travel 13.hours do
      get root_path
      assert_redirected_to login_path
    end
  end

  test "too many login attempts are throttled" do
    10.times { post login_path, params: { username: "admin", password: "wrong" } }
    post login_path, params: { username: "admin", password: "wrong" }
    assert_response :too_many_requests
    assert_select "[role=alert]", text: /Too many sign-in attempts/
  end

  test "expired Turbo frame requests can navigate to the full login page" do
    get root_path, headers: { "Turbo-Frame" => "calendar" }
    follow_redirect!
    assert_select "meta[name='turbo-visit-control'][content=reload]"
    assert_select "nav[aria-label='Main navigation']", count: 0
  end
end
