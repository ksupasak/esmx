require 'test_helper'

class OperationTest < ActiveSupport::TestCase

  # ── Table Name ──

  test "uses esm_operations table" do
    assert_equal 'esm_operations', Operation.table_name
  end

  # ── Associations ──

  test "belongs to service" do
    assoc = Operation.reflect_on_association(:service)
    assert_equal :belongs_to, assoc.macro
  end

  test "belongs to script_template" do
    assoc = Operation.reflect_on_association(:script_template)
    assert_equal :belongs_to, assoc.macro
  end

  # ── Validations ──

  test "name must be unique within service" do
    op = Operation.find_by(name: 'index')
    dup = Operation.new(name: op.name, service_id: op.service_id)
    assert_not dup.valid?
    assert_includes dup.errors[:name], "has already been taken"
  end

  # ── to_s ──

  test "to_s returns title when present and not empty" do
    op = Operation.new(name: 'test', title: 'Test Op')
    assert_equal 'Test Op', op.to_s
  end

  test "to_s returns humanized name when title is empty" do
    op = Operation.new(name: 'test_op', title: '')
    assert_equal 'Test op', op.to_s
  end

  test "to_s returns humanized name when no title" do
    op = Operation.new(name: 'test_op')
    assert_equal 'Test op', op.to_s
  end

  # ── URL ──

  test "url returns correct esm path without domain" do
    op = Operation.find_by(name: 'index')
    expected = "/esm/#{op.service.package.split('.').join('/')}/index"
    assert_equal expected, op.url
  end

  # ── Authorization ──

  test "authorize returns true when acl is wildcard" do
    op = Operation.find_by(name: 'public_page')
    service = op.service
    assert op.authorize(nil, nil, service)
  end

  test "authorize returns true for solution owner" do
    op = Operation.find_by(name: 'admin_page')
    service = op.service
    owner = users(:admin_user)
    assert op.authorize(owner, nil, service)
  end

  test "authorize returns true when role matches acl" do
    op = Operation.find_by(name: 'admin_page')
    service = op.service
    admin = users(:admin_user)
    role = roles(:admin_role)
    assert op.authorize(admin, role, service)
  end

  # ── Escape / Init ──

  test "escape escapes hash interpolation in command" do
    op = Operation.new(command: 'Hello #{name}')
    op.escape
    assert_includes op.command, '\#{'
  end
end
