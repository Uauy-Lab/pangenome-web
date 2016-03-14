class AddMmCountColumnToMutation < ActiveRecord::Migration
  def change
    add_column :mutations, :mm_count, :integer
  end
end
