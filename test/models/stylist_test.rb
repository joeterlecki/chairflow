require "test_helper"

class StylistTest < ActiveSupport::TestCase
  test "active scope excludes inactive stylists" do
    assert_includes Stylist.active, stylists(:melissa)
    assert_not_includes Stylist.active, stylists(:retired)
  end

  test "requires a name" do
    stylist = Stylist.new(swatch: "sage")
    assert_not stylist.valid?
    assert_includes stylist.errors[:name], "can't be blank"
  end

  test "requires a swatch from the known set" do
    stylist = Stylist.new(name: "Jordan", swatch: "magenta")
    assert_not stylist.valid?
    assert_includes stylist.errors[:swatch], "is not included in the list"
  end
end
