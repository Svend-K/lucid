class RemoveColumnRatingFromFactor < ActiveRecord::Migration[5.1]
  def change
    remove_column :factors, :rating
  end
end
