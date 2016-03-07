class AddMutationLibraryIndex < ActiveRecord::Migration
  def change
  	add_index :mutations, [:snp_id, :library_id] , unique: true
  end
end
