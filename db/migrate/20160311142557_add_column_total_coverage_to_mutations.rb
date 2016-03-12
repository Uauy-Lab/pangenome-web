class AddColumnTotalCoverageToMutations < ActiveRecord::Migration
  def change
    add_column :mutations, :total_cov, :integer
  end
end
