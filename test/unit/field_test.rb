require 'test_helper'

class FieldTest < ActiveSupport::TestCase

  # ── Initialization ──

  test "new field generates id" do
    field = Field.new(name: 'Test Field')
    assert_not_nil field.id
    assert field.id.start_with?('F')
    assert_equal 11, field.id.length
  end

  test "new field sets column_name from name" do
    field = Field.new('name' => 'First Name')
    assert_equal 'first_name', field.column_name
  end

  test "new field sets label from name" do
    field = Field.new('name' => 'First Name')
    assert_equal 'First Name', field.label
  end

  test "new field with column_name sets name from it" do
    field = Field.new('column_name' => 'first_name')
    assert_equal 'First name', field.name
    assert_equal 'First name', field.label
  end

  # ── update_attributes ──

  test "update_attributes updates field values" do
    field = Field.new('name' => 'Original')
    field.update_attributes('name' => 'Updated', 'field_type' => 'text_string')
    assert_equal 'Updated', field.name
    assert_equal 'text_string', field.field_type
  end

  test "update_attributes auto-generates column_name when blank" do
    field = Field.new('name' => 'Test')
    field.update_attributes('name' => 'New Name', 'column_name' => '')
    assert_equal 'new_name', field.column_name
  end

  # ── Field Compression ──

  test "get_field_compression excludes blank values" do
    field = Field.new('name' => 'Test', 'field_type' => 'text_string')
    compressed = field.get_field_compression
    assert_kind_of FIELDCOMPRESSION, compressed
    assert_not_nil compressed.attributes[:name]
    assert_not_nil compressed.attributes[:field_type]
    assert_nil compressed.attributes[:css]
  end

  test "get_field_compression strips zero values for boolean-like fields" do
    field = Field.new('name' => 'Test', 'search' => '0', 'list_show' => '0', 'mandatory' => '0')
    compressed = field.get_field_compression
    assert_nil compressed.attributes[:search]
    assert_nil compressed.attributes[:list_show]
    assert_nil compressed.attributes[:mandatory]
  end

  test "load_field_compression restores field from compressed" do
    field = Field.new('name' => 'Test', 'field_type' => 'text_string', 'column_name' => 'test_col')
    compressed = field.get_field_compression

    restored = Field.new
    restored.load_field_compression(compressed)
    assert_equal 'Test', restored.name
    assert_equal 'text_string', restored.field_type
    assert_equal 'test_col', restored.column_name
  end

  # ── LOV Options ──

  test "get_lov_options returns nil when lov_type is nil" do
    field = Field.new('name' => 'Test')
    assert_nil field.get_lov_options
  end

  test "get_lov_options parses plain lov" do
    field = Field.new('name' => 'Test')
    field.lov_type = 'plain'
    field.lov = "Option A\nOption B\nOption C"
    options = field.get_lov_options
    assert_equal 3, options.length
    assert_equal ['Option A', 'Option A'], options[0]
    assert_equal ['Option B', 'Option B'], options[1]
  end

  test "get_lov_options parses pair lov" do
    field = Field.new('name' => 'Test')
    field.lov_type = 'pair'
    field.lov = "key1|Value 1\nkey2|Value 2"
    options = field.get_lov_options
    assert_equal 2, options.length
    assert_equal 'key1', options[0][0]
  end

  # ── Type Lists ──

  test "field_types returns array of type strings" do
    types = Field.field_types
    assert_kind_of Array, types
    assert_includes types, 'text_string'
    assert_includes types, 'text_area'
    assert_includes types, 'select_date'
    assert_includes types, 'relation_one'
    assert_includes types, 'relation_many'
    assert_includes types, 'chapter'
  end

  test "data_types returns hash mapping field types to data types" do
    types = Field.data_types
    assert_kind_of Hash, types
    assert_equal 'String', types['text_string']
    assert_equal 'Integer', types['text_integer']
    assert_equal 'Float', types['text_float']
    assert_equal 'Array', types['relation_many']
    assert_nil types['chapter']
  end

  test "visual_types returns visual-only types" do
    types = Field.visual_types
    assert_includes types, 'section'
    assert_includes types, 'chapter'
    assert_includes types, 'clear'
    assert_includes types, 'html'
    assert_includes types, 'tab'
    assert_not_includes types, 'text_string'
  end
end
