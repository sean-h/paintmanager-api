# Status Key model
class StatusKey < ActiveRecord::Base
  validates :name, presence: true
end
