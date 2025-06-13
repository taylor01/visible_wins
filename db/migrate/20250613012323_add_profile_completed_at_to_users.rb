class AddProfileCompletedAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :profile_completed_at, :datetime
  end
end
