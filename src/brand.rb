# Paint brand model
class Brand < ActiveRecord::Base
  validates :name, presence: true
end
