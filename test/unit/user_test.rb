require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # ── Associations ──

  test "belongs to role" do
    assoc = User.reflect_on_association(:role)
    assert_equal :belongs_to, assoc.macro
  end

  test "belongs to esm" do
    assoc = User.reflect_on_association(:esm)
    assert_equal :belongs_to, assoc.macro
  end

  test "has many esms" do
    assoc = User.reflect_on_association(:esms)
    assert_equal :has_many, assoc.macro
  end

  test "has many accounts" do
    assoc = User.reflect_on_association(:accounts)
    assert_equal :has_many, assoc.macro
  end

  # ── Validations ──

  test "should not save user without login" do
    user = User.new(email: "test@test.com", password: "password", password_confirmation: "password")
    assert_not user.save, "Saved user without login"
  end

  test "should not save user with short login" do
    user = User.new(login: "ab", email: "test@test.com", password: "password", password_confirmation: "password")
    assert_not user.save, "Saved user with login shorter than 3 chars"
  end

  test "should not save user with short password" do
    user = User.new(login: "testuser", email: "test@test.com", password: "abcd", password_confirmation: "abcd")
    assert_not user.save, "Saved user with password shorter than 5 chars"
  end

  test "should not save user when password confirmation does not match" do
    user = User.new(login: "testuser", email: "test@test.com", password: "password", password_confirmation: "different")
    assert_not user.save, "Saved user with mismatched password confirmation"
  end

  test "should not save user with duplicate login" do
    user = users(:admin_user)
    dup = User.new(login: user.login, email: "other@test.com", password: "password", password_confirmation: "password")
    assert_not dup.save, "Saved user with duplicate login"
  end

  test "should not save user with duplicate email" do
    user = users(:admin_user)
    dup = User.new(login: "unique_login", email: user.email, password: "password", password_confirmation: "password")
    assert_not dup.save, "Saved user with duplicate email"
  end

  # ── Password Encryption ──

  test "password is hashed on assignment" do
    user = User.new
    user.password = "secret123"
    assert_not_nil user.salt
    assert_equal Digest::SHA1.hexdigest("secret123" + user.salt), user.hashed_password
  end

  test "encrypt produces consistent SHA1 hash" do
    hash = User.encrypt("mypassword", "mysalt")
    assert_equal Digest::SHA1.hexdigest("mypassword" + "mysalt"), hash
  end

  test "salt is generated only once" do
    user = User.new
    user.password = "first_pass"
    original_salt = user.salt
    user.password = "second_pass"
    assert_equal original_salt, user.salt
  end

  # ── Authentication ──

  test "authenticate returns user with correct credentials" do
    user = User.authenticate("admin", "password")
    assert_not_nil user
    assert_equal "admin", user.login
  end

  test "authenticate returns nil with wrong password" do
    user = User.authenticate("admin", "wrongpassword")
    assert_nil user
  end

  test "authenticate returns nil for non-existent user" do
    user = User.authenticate("nobody", "password")
    assert_nil user
  end

  test "authenticate returns nil for inactive user" do
    user = User.authenticate("inactive", "inactpass")
    assert_nil user
  end

  test "authenticate updates last_accessed on success" do
    before = Time.now
    user = User.authenticate("admin", "password")
    assert_not_nil user.last_accessed
    assert user.last_accessed >= before
  end

  # ── Authorization & Roles ──

  test "developer? returns true for admin role" do
    user = users(:admin_user)
    assert user.developer?
  end

  test "developer? returns true for developer role" do
    user = users(:dev_user)
    assert user.developer?
  end

  test "developer? returns false for regular user without solution" do
    user = users(:regular_user)
    assert_not user.developer?
  end

  test "developer? with solution returns true for solution owner" do
    solution = esms(:test_solution)
    owner = users(:admin_user)
    assert owner.developer?(solution)
  end

  test "allow? returns true for developer role regardless of acl" do
    user = users(:admin_user)
    assert user.allow?('developer', 'admin,user')
  end

  test "allow? returns true when acl is nil" do
    user = users(:regular_user)
    assert user.allow?('user', nil)
  end

  test "allow? returns true when acl is empty" do
    user = users(:regular_user)
    assert user.allow?('user', '')
  end

  test "allow? returns truthy when role is in acl list" do
    user = users(:regular_user)
    assert user.allow?('admin', 'admin, user')
  end

  test "allow? returns falsy when role is not in acl list" do
    user = users(:regular_user)
    assert_not user.allow?('guest', 'admin, user')
  end

  # ── Default Home ──

  test "default_home returns role default_home when set" do
    role = roles(:admin_role)
    role.update(default_home: '/admin/dashboard')
    user = users(:admin_user)
    user.reload
    assert_equal '/admin/dashboard', user.default_home
  end

  test "default_home returns / when role has no default_home" do
    user = users(:regular_user)
    assert_equal '/', user.default_home
  end

  # ── Before Validation Filter ──

  test "filter_before_validation sets email from login when email is nil and login has @" do
    user = User.new(login: "user@example.com")
    user.valid?
    assert_equal "user@example.com", user.email
  end

  # ── Mock User ──

  test "mock_user creates user copy with modified login" do
    original = users(:admin_user)
    solution = esms(:test_solution)
    mock = User.mock_user(original, solution)
    assert_includes mock.login, original.login
    assert_equal solution.id, mock.esm_id
  end

  # ── to_s ──

  test "to_s returns login" do
    user = users(:admin_user)
    assert_equal "admin", user.to_s
  end

  # ── authorize? ──

  test "authorize? returns true when user owns the solution" do
    user = users(:admin_user)
    solution = esms(:test_solution)
    assert user.authorize?(solution)
  end

  test "authorize? returns false when user does not own solution" do
    user = users(:regular_user)
    solution = esms(:test_solution)
    assert_not user.authorize?(solution)
  end
end
