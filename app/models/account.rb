class Account < ApplicationRecord
  
  belongs_to :esm
  belongs_to :user
  belongs_to :role
end
