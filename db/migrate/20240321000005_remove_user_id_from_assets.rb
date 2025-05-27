class RemoveUserIdFromAssets < ActiveRecord::Migration[7.0]
  def change
    remove_reference :assets, :user, foreign_key: true
  end
end 