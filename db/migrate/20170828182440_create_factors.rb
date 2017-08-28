class CreateFactors < ActiveRecord::Migration[5.1]
  def change
    create_table :factors do |t|
      t.string :name
      t.float :rating

      t.timestamps
    end
  end
end
