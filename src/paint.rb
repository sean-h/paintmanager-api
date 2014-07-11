# Paint model
class Paint < ActiveRecord::Base
  validates :range_id, presence: true
end
