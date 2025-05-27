class UpdateAssetsSchema < ActiveRecord::Migration[7.0]
  def up
    # Remove old columns
    remove_reference :assets, :quest, foreign_key: true if column_exists?(:assets, :quest_id)
    remove_reference :assets, :user, foreign_key: true if column_exists?(:assets, :user_id)

    # Ensure name column exists and has correct constraints
    unless column_exists?(:assets, :name)
      add_column :assets, :name, :string, null: false
    else
      change_column_null :assets, :name, false
    end
  end

  def down
    # Add back the removed columns
    add_reference :assets, :quest, foreign_key: true unless column_exists?(:assets, :quest_id)
    add_reference :assets, :user, foreign_key: true unless column_exists?(:assets, :user_id)
  end
end 