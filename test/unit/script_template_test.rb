require 'test_helper'

class ScriptTemplateTest < ActiveSupport::TestCase

  # ── Table Name ──

  test "uses esm_templates table" do
    assert_equal 'esm_templates', ScriptTemplate.table_name
  end

  # ── Generate ──

  test "generate evaluates ERB with command binding" do
    template = ScriptTemplate.new(
      name: 'TestTemplate',
      generator: '"<%= command %>"'
    )
    result = template.generate('<h1>Hello</h1>', nil, {})
    assert_equal '"<h1>Hello</h1>"', result
  end

  # ── to_s ──

  test "to_s removes last 8 chars from name" do
    template = ScriptTemplate.new(name: 'HTMLTemplate')
    assert_equal 'HTML', template.to_s
  end
end
