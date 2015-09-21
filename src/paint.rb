# Paint model
class Paint < ActiveRecord::Base
  validates :range_id, presence: true
  validates :name, presence: true
  validates :color, presence: true
end
