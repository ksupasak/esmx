require 'test_helper'

class MenuActionTest < ActiveSupport::TestCase

  # ── Associations ──

  test "has many child menu_actions" do
    assoc = MenuAction.reflect_on_association(:menu_actions)
    assert_equal :has_many, assoc.macro
    assert_equal 'parent_id', assoc.foreign_key
  end

  test "belongs to project" do
    assoc = MenuAction.reflect_on_association(:project)
    assert_equal :belongs_to, assoc.macro
  end

  # ── Scopes ──

  test "published scope returns only published items" do
    published = MenuAction.published
    published.each do |action|
      assert action.published, "Non-published item in published scope"
    end
  end

  test "root scope returns items without parent and published" do
    root_items = MenuAction.root
    root_items.each do |action|
      assert_nil action.parent_id, "Root scope item has parent_id"
      assert action.published, "Root scope item not published"
    end
  end

  test "root scope excludes child items" do
    root_items = MenuAction.root
    child = menu_actions(:child_menu)
    assert_not_includes root_items, child
  end

  test "root scope excludes unpublished items" do
    root_items = MenuAction.root
    hidden = menu_actions(:unpublished_menu)
    assert_not_includes root_items, hidden
  end

  # ── Parent-Child ──

  test "parent has children" do
    parent = menu_actions(:root_menu)
    assert parent.menu_actions.count > 0
    assert_includes parent.menu_actions, menu_actions(:child_menu)
  end
end
