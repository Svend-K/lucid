class RemoveTypeFromProfiles < ActiveRecord::Migration[5.1]
  def change
    remove_column :profiles, :type
  end
end
