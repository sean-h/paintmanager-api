# Barcode model
class Barcode < ActiveRecord::Base
  validates :paint_id, presence: true
  validates :barcode, presence: true
end
