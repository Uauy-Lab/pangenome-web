class AddMutationLibraryIndex < ActiveRecord::Migration[6.0]
  def change
  	add_index :mutations, [:snp_id, :library_id] , unique: true
  end
end
