class Quest < ApplicationRecord
  has_many :quest_participants, dependent: :destroy
  has_many :users, through: :quest_participants
  has_many :quest_assets, dependent: :destroy
  has_many :assets, through: :quest_assets

  validates :name, presence: true
  validates :status, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :boundary, presence: true

  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }

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
    
    # Convert input coordinates to floats
    lat = lat.to_f
    lng = lng.to_f
    
    # Simple point-in-polygon check
    point_in_polygon?(lat, lng, coordinates)
  end

  # Find all quests that contain a given point
  scope :containing_point, ->(lat, lng) {
    all.select { |quest| quest.contains_point?(lat, lng) }
  }

  def check_completion!
    return if status == 'completed'
    
    if all_assets_collected?
      update!(status: 'completed')
      quest_participants.active.each(&:complete!)
    end
  end

  def all_assets_collected?
    quest_assets.available.none?
  end

  def user_collection_stats(user)
    {
      total_assets: quest_assets.count,
      collected_by_user: quest_assets.where(collected_by: user).count,
      remaining_assets: quest_assets.available.count
    }
  end

  private

  def point_in_polygon?(lat, lng, coordinates)
    inside = false
    j = coordinates.length - 1
    
    coordinates.each_with_index do |point, i|
      # Convert coordinates to floats
      point_lng = point[0].to_f
      point_lat = point[1].to_f
      next_point_lng = coordinates[j][0].to_f
      next_point_lat = coordinates[j][1].to_f
      
      # Ensure all values are floats for comparison
      lat = lat.to_f
      lng = lng.to_f
      
      if ((point_lat > lat) != (next_point_lat > lat)) &&
         (lng < (next_point_lng - point_lng) * (lat - point_lat) / 
         (next_point_lat - point_lat) + point_lng)
        inside = !inside
      end
      j = i
    end
    
    inside
  end
end
