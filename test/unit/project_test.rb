require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  # ── Table Name ──

  test "uses esm_projects table" do
    assert_equal 'esm_projects', Project.table_name
  end

  # ── Associations ──

  test "belongs to esm" do
    assoc = Project.reflect_on_association(:esm)
    assert_equal :belongs_to, assoc.macro
  end

  test "has one schema" do
    assoc = Project.reflect_on_association(:schema)
    assert_equal :has_one, assoc.macro
  end

  test "has many services with dependent delete_all" do
    assoc = Project.reflect_on_association(:services)
    assert_equal :has_many, assoc.macro
    assert_equal :delete_all, assoc.options[:dependent]
  end

  test "has many documents with dependent delete_all" do
    assoc = Project.reflect_on_association(:documents)
    assert_equal :has_many, assoc.macro
    assert_equal :delete_all, assoc.options[:dependent]
  end

  test "has many menu_actions with dependent delete_all" do
    assoc = Project.reflect_on_association(:menu_actions)
    assert_equal :has_many, assoc.macro
    assert_equal :delete_all, assoc.options[:dependent]
  end

  test "has many settings with dependent delete_all" do
    assoc = Project.reflect_on_association(:settings)
    assert_equal :has_many, assoc.macro
    assert_equal :delete_all, assoc.options[:dependent]
  end

  test "has many roles with dependent delete_all" do
    assoc = Project.reflect_on_association(:roles)
    assert_equal :has_many, assoc.macro
    assert_equal :delete_all, assoc.options[:dependent]
  end

  # ── Validations ──

  test "name must be unique within esm" do
    existing = Project.find_by(name: 'www', esm_id: esms(:test_solution).id)
    dup = Project.new(name: existing.name, esm_id: existing.esm_id)
    assert_not dup.valid?
    assert_includes dup.errors[:name], "has already been taken"
  end

  test "package must be unique" do
    existing = Project.find_by(package: 'test_solution.www')
    dup = Project.new(name: 'other', package: existing.package, esm_id: esms(:unpublished_solution).id)
    assert_not dup.valid?
    assert_includes dup.errors[:package], "has already been taken"
  end

  # ── Before Save ──

  test "before_save sets package from esm name and project name" do
    esm = esms(:test_solution)
    project = Project.new(name: 'newproj', esm: esm)
    project.valid?
    # package is set in before_save
    assert_equal "#{esm.name}.newproj", project.package
  end

  # ── to_s ──

  test "to_s returns title when present" do
    project = Project.new(title: 'My Title', name: 'myname')
    assert_equal 'My Title', project.to_s
  end

  test "to_s returns humanized name when no title" do
    project = Project.new(name: 'myname')
    assert_equal 'Myname', project.to_s
  end

  test "to_s returns Untitled when no name or title" do
    project = Project.new
    assert_equal 'Untitled', project.to_s
  end

  # ── get_params ──

  test "get_params returns empty hash when params is nil" do
    project = Project.new
    assert_equal({}, project.get_params)
  end

  test "get_params returns empty hash when params is empty string" do
    project = Project.new(params: '')
    assert_equal({}, project.get_params)
  end

  test "get_params returns empty hash when params is null string" do
    project = Project.new(params: 'null')
    assert_equal({}, project.get_params)
  end

  test "get_params parses valid JSON" do
    project = Project.new(params: '{"app_title":"Test"}')
    result = project.get_params
    assert_equal 'Test', result['app_title']
  end

  # ── params_list ──

  test "params_list returns expected parameter names" do
    list = Project.params_list
    assert_includes list, 'app_title'
    assert_includes list, 'app_logo_url'
    assert_includes list, 'app_theme'
  end
end
