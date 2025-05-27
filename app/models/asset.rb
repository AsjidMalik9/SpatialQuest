class Asset < ApplicationRecord
  has_many :quest_assets, dependent: :destroy
  has_many :quests, through: :quest_assets
  has_many :collected_by, through: :quest_assets, source: :collected_by

  validates :name, presence: true
  validates :content, presence: true

  def collect_in_quest!(quest, user)
    quest_asset = quest_assets.find_by(quest: quest)
    return false unless quest_asset&.status == 'available'
    return false unless quest.contains_point?(quest_asset.latitude, quest_asset.longitude)
    
    quest_asset.collect!(user)
  end

  def place_in_quest!(quest)
    quest_asset = quest_assets.find_by(quest: quest)
    return false unless quest_asset&.status == 'collected'
    
    quest_asset.place!
  end

  def status_in_quest(quest)
    quest_assets.find_by(quest: quest)&.status
  end

  def collected_by_in_quest(quest)
    quest_assets.find_by(quest: quest)&.collected_by
  end
end
