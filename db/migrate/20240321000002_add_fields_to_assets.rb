class AddFieldsToAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :assets, :name, :string
    add_column :assets, :status, :string, default: 'available'
    add_column :assets, :collected_at, :datetime
    add_column :assets, :placed_at, :datetime
    add_index :assets, [:quest_id, :latitude, :longitude], unique: true
  end
end 