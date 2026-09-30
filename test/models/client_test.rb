require "test_helper"

class ClientTest < ActiveSupport::TestCase
  test "requires a name" do
    client = Client.new
    assert_not client.valid?
    assert_includes client.errors[:name], "can't be blank"
  end

  test "normalizes email by stripping and downcasing" do
    client = Client.new(name: "Jamie", email: "  Jamie@Example.COM  ")
    assert_equal "jamie@example.com", client.email
  end

  test "normalizes phone by keeping only digits and a leading plus" do
    client = Client.new(name: "Jamie", phone: "(555) 123-4567")
    assert_equal "5551234567", client.phone
  end

  test "matching scope finds clients by partial name" do
    assert_includes Client.matching("thom"), clients(:ava)
    assert_not_includes Client.matching("thom"), clients(:noah)
  end

  test "possible_duplicates_of matches on name regardless of case" do
    duplicates = Client.possible_duplicates_of(name: "AVA THOMPSON")
    assert_includes duplicates, clients(:ava)
  end

  test "possible_duplicates_of matches on email" do
    duplicates = Client.possible_duplicates_of(name: "Someone Else", email: "ava@example.com")
    assert_includes duplicates, clients(:ava)
  end

  test "possible_duplicates_of matches on phone" do
    duplicates = Client.possible_duplicates_of(name: "Someone Else", phone: "555.123.4567")
    assert_includes duplicates, clients(:ava)
  end

  test "possible_duplicates_of finds nothing for an unrelated client" do
    duplicates = Client.possible_duplicates_of(name: "Completely Different", email: "nobody@example.com")
    assert_empty duplicates
  end
end
