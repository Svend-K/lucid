class RemoveColumnScoreFromIndex < ActiveRecord::Migration[5.1]
  def change
    remove_column :indices, :score
  end
end
