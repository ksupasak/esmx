require 'test_helper'

class DocumentTest < ActiveSupport::TestCase

  # ── Table Name ──

  test "uses esm_documents table" do
    assert_equal 'esm_documents', Document.table_name
  end

  # ── Associations ──

  test "belongs to project" do
    assoc = Document.reflect_on_association(:project)
    assert_equal :belongs_to, assoc.macro
  end

  test "belongs to table" do
    assoc = Document.reflect_on_association(:table)
    assert_equal :belongs_to, assoc.macro
  end

  test "belongs to service" do
    assoc = Document.reflect_on_association(:service)
    assert_equal :belongs_to, assoc.macro
  end

  # ── Class Methods ──

  test "version returns version string" do
    assert_not_nil Document.version
    assert_kind_of String, Document.version
  end

  test "field_types returns comprehensive list" do
    types = Document.field_types
    assert_kind_of Array, types
    assert types.length > 20
    assert_includes types, 'text_string'
    assert_includes types, 'text_area'
    assert_includes types, 'text_integer'
    assert_includes types, 'text_float'
    assert_includes types, 'select_string'
    assert_includes types, 'select_date'
    assert_includes types, 'image_camera'
    assert_includes types, 'map_location'
    assert_includes types, 'relation_one'
    assert_includes types, 'relation_many'
    assert_includes types, 'extra_signature'
    assert_includes types, 'extra_attachment'
  end

  test "data_types maps field types to mongoid types" do
    types = Document.data_types
    assert_equal 'String', types['text_string']
    assert_equal 'String', types['text_area']
    assert_equal 'Integer', types['text_integer']
    assert_equal 'Float', types['text_float']
    assert_equal 'Date', types['select_date']
    assert_equal 'Time', types['select_time']
    assert_equal 'Array', types['image_camera']
    assert_equal 'Array', types['relation_many']
    assert_equal 'ObjectId', types['relation_one']
    assert_nil types['chapter']
    assert_nil types['section']
  end

  test "visual_types returns layout-only types" do
    types = Document.visual_types
    assert_includes types, 'section'
    assert_includes types, 'chapter'
    assert_includes types, 'clear'
    assert_includes types, 'html'
    assert_includes types, 'tab'
    assert_equal 5, types.length
  end
end
