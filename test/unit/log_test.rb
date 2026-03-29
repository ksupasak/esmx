require 'test_helper'

class LogTest < ActiveSupport::TestCase

  test "can create log entry" do
    log = Log.new(
      user_id: 1,
      role_id: 1,
      remote_ip: '127.0.0.1',
      action: 'login',
      path: '/esm_home',
      remark: 'test login',
      esm_id: 1
    )
    assert log.save
  end

  test "log stores all fields correctly" do
    log = Log.create!(
      user_id: 1,
      role_id: 1,
      remote_ip: '192.168.1.1',
      action: 'create',
      path: '/manage/users',
      remark: 'created user',
      esm_id: 1
    )
    log.reload
    assert_equal '192.168.1.1', log.remote_ip
    assert_equal 'create', log.action
    assert_equal '/manage/users', log.path
  end
end
