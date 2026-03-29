require 'test_helper'

class RoleTest < ActiveSupport::TestCase

  # ── Associations ──

  test "belongs to project" do
    assoc = Role.reflect_on_association(:project)
    assert_equal :belongs_to, assoc.macro
  end

  test "has many accounts" do
    assoc = Role.reflect_on_association(:accounts)
    assert_equal :has_many, assoc.macro
  end

  # ── developer? ──

  test "developer? returns true for developer role" do
    role = roles(:developer_role)
    assert role.developer?
  end

  test "developer? returns false for admin role" do
    role = roles(:admin_role)
    assert_not role.developer?
  end

  test "developer? returns false for user role" do
    role = roles(:user_role)
    assert_not role.developer?
  end

  # ── to_s ──

  test "to_s returns humanized name" do
    role = roles(:admin_role)
    assert_equal 'Admin', role.to_s
  end
end
