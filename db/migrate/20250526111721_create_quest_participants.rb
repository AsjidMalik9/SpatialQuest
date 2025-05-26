class CreateQuestParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :quest_participants do |t|
      t.references :quest, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
