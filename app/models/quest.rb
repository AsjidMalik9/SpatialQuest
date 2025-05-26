class Quest < ApplicationRecord
  has_many :quest_participants, dependent: :destroy
  has_many :users, through: :quest_participants
  has_many :assets, dependent: :destroy

  validates :name, presence: true
  validates :status, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :boundary, presence: true

  scope :active, -> { where(status: 'active') }

  # Find quests that contain a user's current location
  scope :near_user, ->(user) {
    return none unless user.latitude.present? && user.longitude.present?
    all.select { |quest| quest.contains_point?(user.latitude, user.longitude) }
  }

  # Check if a point (latitude, longitude) is within the quest's boundary
  def contains_point?(lat, lng)
    return false unless boundary.present?
    
    # Parse the boundary polygon from GeoJSON
    polygon = JSON.parse(boundary)
    coordinates = polygon['coordinates'][0]
    
    # Simple point-in-polygon check
    point_in_polygon?(lat, lng, coordinates)
  end

  # Find all quests that contain a given point
  scope :containing_point, ->(lat, lng) {
    all.select { |quest| quest.contains_point?(lat, lng) }
  }

  private

  def point_in_polygon?(lat, lng, coordinates)
    inside = false
    j = coordinates.length - 1
    
    coordinates.each_with_index do |point, i|
      if ((point[1] > lat) != (coordinates[j][1] > lat)) &&
         (lng < (coordinates[j][0] - point[0]) * (lat - point[1]) / 
         (coordinates[j][1] - point[1]) + point[0])
        inside = !inside
      end
      j = i
    end
    
    inside
  end
end
