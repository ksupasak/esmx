require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  # ── Associations ──

  test "belongs to esm" do
    assoc = Account.reflect_on_association(:esm)
    assert_equal :belongs_to, assoc.macro
  end

  test "belongs to user" do
    assoc = Account.reflect_on_association(:user)
    assert_equal :belongs_to, assoc.macro
  end

  test "belongs to role" do
    assoc = Account.reflect_on_association(:role)
    assert_equal :belongs_to, assoc.macro
  end

  # ── CRUD ──

  test "can create account with valid attributes" do
    account = Account.new(
      esm_id: esms(:test_solution).id,
      user_id: users(:regular_user).id,
      role_id: roles(:user_role).id,
      active: true
    )
    assert account.save
  end

  test "account links user role and esm" do
    account = accounts(:dev_account)
    assert_equal users(:dev_user), account.user
    assert_equal roles(:developer_role), account.role
    assert_equal esms(:test_solution), account.esm
  end
end
