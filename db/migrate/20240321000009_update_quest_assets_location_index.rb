class UpdateQuestAssetsLocationIndex < ActiveRecord::Migration[7.0]
  def up
    # Remove the old index
    remove_index :quest_assets, [:quest_id, :latitude, :longitude]
    
    # Add a partial index that only applies to available assets
    add_index :quest_assets, [:quest_id, :latitude, :longitude], 
              unique: true, 
              where: "status = 'available'",
              name: 'index_quest_assets_on_quest_and_location_when_available'
  end

  def down
    # Remove the partial index
    remove_index :quest_assets, name: 'index_quest_assets_on_quest_and_location_when_available'
    
    # Add back the original index
    add_index :quest_assets, [:quest_id, :latitude, :longitude], unique: true
  end
end 