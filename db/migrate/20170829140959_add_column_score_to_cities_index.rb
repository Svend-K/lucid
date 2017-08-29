class AddColumnScoreToCitiesIndex < ActiveRecord::Migration[5.1]
  def change
    add_column :cities_indices, :score, :float
  end
end
