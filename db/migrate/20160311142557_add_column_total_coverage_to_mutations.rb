class AddColumnTotalCoverageToMutations < ActiveRecord::Migration[6.0]
  def change
    add_column :mutations, :total_cov, :integer
  end
end
