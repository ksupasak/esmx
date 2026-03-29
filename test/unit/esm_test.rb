require 'test_helper'

class EsmTest < ActiveSupport::TestCase

  # ── Associations ──

  test "belongs to user" do
    assoc = Esm.reflect_on_association(:user)
    assert_equal :belongs_to, assoc.macro
  end

  test "has many projects" do
    assoc = Esm.reflect_on_association(:projects)
    assert_equal :has_many, assoc.macro
  end

  test "has many roles" do
    assoc = Esm.reflect_on_association(:roles)
    assert_equal :has_many, assoc.macro
  end

  test "has many users" do
    assoc = Esm.reflect_on_association(:users)
    assert_equal :has_many, assoc.macro
  end

  test "has many logs" do
    assoc = Esm.reflect_on_association(:logs)
    assert_equal :has_many, assoc.macro
  end

  test "has many settings with dependent delete_all" do
    assoc = Esm.reflect_on_association(:settings)
    assert_equal :has_many, assoc.macro
    assert_equal :delete_all, assoc.options[:dependent]
  end

  test "has many menu_actions with dependent delete_all" do
    assoc = Esm.reflect_on_association(:menu_actions)
    assert_equal :has_many, assoc.macro
    assert_equal :delete_all, assoc.options[:dependent]
  end

  test "has many projects with dependent delete_all" do
    assoc = Esm.reflect_on_association(:projects)
    assert_equal :delete_all, assoc.options[:dependent]
  end

  # ── Validations ──

  test "should not save esm with duplicate name" do
    existing = esms(:test_solution)
    dup = Esm.new(name: existing.name, user_id: 1)
    assert_not dup.save, "Saved ESM with duplicate name"
  end

  # ── Scopes ──

  test "published scope returns only published solutions" do
    published = Esm.published
    published.each do |esm|
      assert esm.published, "Non-published ESM in published scope"
    end
  end

  # ── Instance Methods ──

  test "to_s returns humanized name" do
    esm = esms(:test_solution)
    assert_equal esm.name.humanize, esm.to_s
  end

  test "get_solution finds by name" do
    esm = Esm.get_solution('test_solution')
    assert_not_nil esm
    assert_equal 'test_solution', esm.name
  end

  test "get_solution returns nil for non-existent" do
    assert_nil Esm.get_solution('nonexistent')
  end

  test "get_project returns project by name" do
    esm = esms(:test_solution)
    project = esm.get_project('www')
    assert_not_nil project
    assert_equal 'www', project.name
  end

  test "get_project returns nil for non-existent project" do
    esm = esms(:test_solution)
    assert_nil esm.get_project('nonexistent')
  end

  test "get_www returns www project" do
    esm = esms(:test_solution)
    www = esm.get_www
    assert_not_nil www
    assert_equal 'www', www.name
  end

  test "get_users returns associated users" do
    esm = esms(:test_solution)
    users = esm.get_users
    assert_kind_of ActiveRecord::Relation, users
  end

  # ── Developer Check ──

  test "developer? returns true for solution owner" do
    esm = esms(:test_solution)
    owner = users(:admin_user)
    assert esm.developer?(owner)
  end

  test "developer? returns true for admin user" do
    esm = esms(:test_solution)
    admin = users(:admin_user)
    assert esm.developer?(admin)
  end

  test "developer? returns false for regular user without developer account" do
    esm = esms(:test_solution)
    regular = users(:regular_user)
    assert_not esm.developer?(regular)
  end
end
