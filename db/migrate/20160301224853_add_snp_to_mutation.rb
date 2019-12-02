class AddSnpToMutation < ActiveRecord::Migration[6.0]
  def change
    add_reference :mutations, :snp, index: true
    add_foreign_key :mutations, :snps
  end
end
