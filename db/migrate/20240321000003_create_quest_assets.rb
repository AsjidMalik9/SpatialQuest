class CreateQuestAssets < ActiveRecord::Migration[7.0]
  def change
    create_table :quest_assets do |t|
      t.references :quest, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true
      t.float :latitude
      t.float :longitude
      t.string :status, default: 'available' # available, collected, placed
      t.references :collected_by, foreign_key: { to_table: :users }
      t.datetime :collected_at
      t.datetime :placed_at
      t.string :hint
      t.text :quest_specific_content

      t.timestamps
    end

    add_index :quest_assets, [:quest_id, :latitude, :longitude], unique: true
    add_index :quest_assets, [:quest_id, :asset_id], unique: true
  end
end 