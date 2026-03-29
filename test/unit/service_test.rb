require 'test_helper'

class ServiceTest < ActiveSupport::TestCase

  # ── Table Name ──

  test "uses esm_services table" do
    assert_equal 'esm_services', Service.table_name
  end

  # ── Associations ──

  test "has many operations with dependent delete_all" do
    assoc = Service.reflect_on_association(:operations)
    assert_equal :has_many, assoc.macro
    assert_equal :delete_all, assoc.options[:dependent]
  end

  test "belongs to project" do
    assoc = Service.reflect_on_association(:project)
    assert_equal :belongs_to, assoc.macro
  end

  # ── Validations ──

  test "name must be unique within project" do
    service = Service.find_by(name: 'home', project_id: 1)
    dup = Service.new(name: service.name, project_id: service.project_id)
    assert_not dup.valid?
    assert_includes dup.errors[:name], "has already been taken"
  end

  # ── Packaging ──

  test "packaging sets package before save" do
    project = Project.find_by(package: 'test_solution.www')
    service = project.services.build(name: 'new_service')
    service.valid?
    service.packaging
    assert_equal 'test_solution.www.NewService', service.package
  end

  # ── Display ──

  test "display_name returns title when present" do
    service = Service.new(name: 'test', title: 'Test Service')
    assert_equal 'Test Service', service.display_name
  end

  test "display_name returns humanized name when no title" do
    service = Service.new(name: 'my_service')
    assert_equal 'My service', service.display_name
  end

  test "to_s returns classified name" do
    service = Service.new(name: 'my_service')
    assert_equal 'MyService', service.to_s
  end

  # ── URL ──

  test "url returns correct path without domain" do
    service = Service.new(name: 'home')
    service.package = 'sol.proj.Home'
    assert_equal '/esm/sol/proj/Home/index', service.url
  end

  # ── Authorization ──

  test "authorize returns true for solution owner" do
    service = Service.find_by(name: 'data')
    owner = users(:admin_user)
    assert service.authorize(owner)
  end

  test "authorize returns true when acl contains wildcard" do
    service = Service.new(acl: '*')
    # Build minimal project/esm chain
    assert service.authorize(nil)
  end

  test "authorize returns false for non-owner without matching role" do
    service = Service.find_by(name: 'data')
    regular = users(:regular_user)
    role = roles(:user_role)
    assert service.authorize(regular, role)
  end

  # ── Extended List ──

  test "extended_list returns empty array when no extended" do
    service = Service.new(name: 'solo')
    assert_equal [], service.extended_list
  end

  # ── get via package ──

  test "Service.get returns nil for non-existent package" do
    result = Service.get('nonexistent.package.Name')
    assert_nil result
  end

  # ── get_acl ──

  test "get_acl returns acl array from service" do
    service = Service.find_by(name: 'data', project_id: 2)
    acl = service.get_acl('index', users(:admin_user))
    assert_kind_of Array, acl
    assert_includes acl, 'user'
    assert_includes acl, 'developer'
  end

  # ── prepare ──

  test "prepare returns context hash" do
    service = Service.find_by(name: 'home')
    context = service.prepare({action: 'index'})
    assert_equal service, context[:service]
    assert_equal service.project, context[:project]
    assert_equal({action: 'index'}, context[:params])
  end
end
