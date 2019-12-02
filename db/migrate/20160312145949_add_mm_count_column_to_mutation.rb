class AddMmCountColumnToMutation < ActiveRecord::Migration[6.0]
  def change
    add_column :mutations, :mm_count, :integer
  end
end
