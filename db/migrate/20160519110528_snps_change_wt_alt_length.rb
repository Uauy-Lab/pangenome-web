class SnpsChangeWtAltLength < ActiveRecord::Migration[6.0]
  def change
  	change_column :snps, :wt, :string , :limit => 8
  	change_column :snps, :alt, :string , :limit => 8
  end
end
