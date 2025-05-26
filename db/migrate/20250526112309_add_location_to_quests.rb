class AddLocationToQuests < ActiveRecord::Migration[7.1]
  def change
    add_column :quests, :latitude, :float
    add_column :quests, :longitude, :float
    add_column :quests, :boundary, :text
  end
end
