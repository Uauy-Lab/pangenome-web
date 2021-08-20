class RemoveMutation < ActiveRecord::Migration[6.1]
  def change
    drop_table :mutation_consequences
    drop_table :mutations
  end
end
