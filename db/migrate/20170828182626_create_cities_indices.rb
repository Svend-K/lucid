class CreateCitiesIndices < ActiveRecord::Migration[5.1]
  def change
    create_table :cities_indices do |t|
      t.references :city, foreign_key: true
      t.references :index, foreign_key: true

      t.timestamps
    end
  end
end
