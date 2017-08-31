class DropUsersFactorsTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :users_factors
  end
end
