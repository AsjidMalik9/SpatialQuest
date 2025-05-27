class QuestAsset < ApplicationRecord
  belongs_to :quest
  belongs_to :asset
  belongs_to :collected_by, class_name: 'User', optional: true

  validates :latitude, :longitude, presence: true
  validates :status, presence: true, inclusion: { in: %w[available collected placed] }
  validates :quest_id, uniqueness: { scope: [:latitude, :longitude] }, if: :available?

  scope :available, -> { where(status: 'available') }
  scope :collected, -> { where(status: 'collected') }
  scope :placed, -> { where(status: 'placed') }

  def collect!(user)
    return false unless status == 'available'
    
    transaction do
      update!(
        status: 'collected',
        collected_by: user,
        collected_at: Time.current
      )
    end
  end

  def place!
    return false unless status == 'collected'
    
    transaction do
      update!(
        status: 'placed',
        placed_at: Time.current,
        latitude: latitude,
        longitude: longitude
      )
    end
  end

  private

  def available?
    status == 'available'
  end
end 