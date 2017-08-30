class CreateCitiesItems < ActiveRecord::Migration[5.1]
  def change
    create_table :cities_items do |t|
      t.float :price
      t.references :city, foreign_key: true
      t.references :item, foreign_key: true

      t.timestamps
    end
  end
end
