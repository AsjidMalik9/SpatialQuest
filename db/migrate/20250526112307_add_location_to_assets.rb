class AddLocationToAssets < ActiveRecord::Migration[7.1]
  def change
    add_column :assets, :latitude, :float
    add_column :assets, :longitude, :float
  end
end
