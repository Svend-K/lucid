class CreateCitiesFactors < ActiveRecord::Migration[5.1]
  def change
    create_table :cities_factors do |t|
      t.references :city, foreign_key: true
      t.references :factor, foreign_key: true

      t.timestamps
    end
  end
end
