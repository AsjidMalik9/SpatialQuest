class User < ApplicationRecord
  has_many :quest_participants, dependent: :destroy
  has_many :quests, through: :quest_participants
  has_many :assets, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  serialize :current_location, JSON

  def update_location(latitude, longitude)
    update(current_location: {
      latitude: latitude,
      longitude: longitude,
      updated_at: Time.current
    })
  end

  def current_latitude
    current_location&.dig('latitude')
  end

  def current_longitude
    current_location&.dig('longitude')
  end

  def location_updated_at
    current_location&.dig('updated_at')
  end
end
