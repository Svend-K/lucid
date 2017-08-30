class RemoveUserFromProfile < ActiveRecord::Migration[5.1]
  def change
    remove_column :profiles, :user_id
  end
end
