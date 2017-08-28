class CreateUsersFactors < ActiveRecord::Migration[5.1]
  def change
    create_table :users_factors do |t|
      t.references :user, foreign_key: true
      t.references :factor, foreign_key: true

      t.timestamps
    end
  end
end
