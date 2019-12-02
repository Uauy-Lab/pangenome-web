class CreateJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :chromosomes, :scaffolds do |t|
       t.index [:chromosome_id, :scaffold_id]
       t.index [:scaffold_id, :chromosome_id]
    end
  end
end
