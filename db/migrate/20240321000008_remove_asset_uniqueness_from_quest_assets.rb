class RemoveAssetUniquenessFromQuestAssets < ActiveRecord::Migration[7.0]
  def change
    remove_index :quest_assets, [:quest_id, :asset_id]
  end
end 