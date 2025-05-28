class User < ApplicationRecord
  has_many :quest_participants, dependent: :destroy
  has_many :quests, through: :quest_participants
  has_many :quest_assets, foreign_key: :collected_by_id, dependent: :nullify
  has_many :collected_assets, through: :quest_assets, source: :asset

  validates :email, presence: true, uniqueness: true

  def update_location(latitude, longitude)
    # Clear location cache when updating
    Rails.cache.delete("user_#{id}_location")
    update(latitude: latitude, longitude: longitude)
  end

  def current_latitude
    Rails.cache.fetch("user_#{id}_location") do
      { latitude: latitude, longitude: longitude }
    end[:latitude]
  end

  def current_longitude
    Rails.cache.fetch("user_#{id}_location") do
      { latitude: latitude, longitude: longitude }
    end[:longitude]
  end

  def location_updated_at
    updated_at
  end
end
