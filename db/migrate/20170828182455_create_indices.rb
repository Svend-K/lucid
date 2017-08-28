class CreateIndices < ActiveRecord::Migration[5.1]
  def change
    create_table :indices do |t|
      t.string :name
      t.float :score

      t.timestamps
    end
  end
end
