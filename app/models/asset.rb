class Asset < ApplicationRecord
  belongs_to :quest
  belongs_to :user

  validates :content, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
end
