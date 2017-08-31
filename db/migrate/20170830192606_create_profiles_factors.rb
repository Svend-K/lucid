class CreateProfilesFactors < ActiveRecord::Migration[5.1]
  def change
    create_table :profiles_factors do |t|
      t.references :profile, foreign_key: true
      t.references :factor, foreign_key: true

      t.timestamps
    end
  end
end
