# Paint Range model
class PaintRange < ActiveRecord::Base
  self.table_name = 'ranges'
  validates :brand_id, presence: true
end
