class QuestParticipant < ApplicationRecord
  belongs_to :quest
  belongs_to :user

  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :quest_id }
end
