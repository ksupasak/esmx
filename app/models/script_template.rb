

class ScriptTemplate < ApplicationRecord
  
  self.table_name = :esm_templates
  # attr_accessor :name,:generator,:template
  
   def generate command, this,  params
     return ERB.new(self.generator).result(binding)
   end
   def to_s
      self.name[0..-9]
   end
end

