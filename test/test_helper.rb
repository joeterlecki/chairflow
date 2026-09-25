ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  setup do
    SessionsController.cache_store.clear
    post login_path, params: { username: "admin", password: "studio-test-password" } if authenticate_for_test?
  end

  def authenticate_for_test?
    true
  end
end
