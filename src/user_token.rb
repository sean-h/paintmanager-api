require 'securerandom'

# UserToken model
class UserToken < ActiveRecord::Base
  validates :user_id, presence: true
  validates :token, presence: true, uniqueness: true
  validates :expires, presence: true

  before_validation(on: :create) do
    self.token = SecureRandom.uuid
    self.expires = Time.now + 60_400 # 7 days
  end
end
