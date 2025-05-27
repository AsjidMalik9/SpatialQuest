class QuestParticipant < ApplicationRecord
  belongs_to :quest
  belongs_to :user

  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :quest_id }

  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :left, -> { where(status: 'left') }

  def leave!
    update!(status: 'left')
  end

  def complete!
    update!(status: 'completed')
  end
end
