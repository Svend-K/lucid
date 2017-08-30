class AddColumnRatingToCitiesFactor < ActiveRecord::Migration[5.1]
  def change
    add_column :cities_factors, :score, :float
  end
end
