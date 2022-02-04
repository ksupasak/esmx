class Role < ApplicationRecord
  
  belongs_to :project 
  has_many :accounts
  
  # attr_accessor :name,:description,:default_home,:esm_id
  
  def to_s
        self.name.humanize
  end
  
  
  def developer?
    self.name=='developer'
  end
end
