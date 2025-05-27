class RemoveQuestIdFromAssets < ActiveRecord::Migration[7.0]
  def change
    remove_reference :assets, :quest, foreign_key: true
  end
end 