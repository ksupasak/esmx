require 'test_helper'

class PermissionTest < ActiveSupport::TestCase

  test "can create permission" do
    perm = Permission.new(
      name: 'test_perm',
      menu_action_id: 1,
      role_id: 1
    )
    assert perm.save
  end

  test "can read permission" do
    perm = permissions(:admin_perm)
    assert_equal 'admin_access', perm.name
    assert_equal 1, perm.menu_action_id
    assert_equal 1, perm.role_id
  end
end
