require 'test_helper'

class SettingTest < ActiveSupport::TestCase

  # ── Associations ──

  test "belongs to project" do
    assoc = Setting.reflect_on_association(:project)
    assert_equal :belongs_to, assoc.macro
  end

  # ── CRUD ──

  test "can create setting" do
    setting = Setting.new(
      name: 'new_setting',
      value: 'new_value',
      project_id: 1,
      esm_id: 1
    )
    assert setting.save
  end

  test "can read setting value" do
    setting = settings(:app_title_setting)
    assert_equal 'app_title', setting.name
    assert_equal 'Test App', setting.value
  end

  test "can update setting value" do
    setting = settings(:theme_setting)
    setting.update(value: 'dark')
    setting.reload
    assert_equal 'dark', setting.value
  end

  test "can destroy setting" do
    setting = settings(:theme_setting)
    assert_difference 'Setting.count', -1 do
      setting.destroy
    end
  end
end
