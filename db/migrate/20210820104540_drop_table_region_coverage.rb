class DropTableRegionCoverage < ActiveRecord::Migration[6.1]
  def change
    drop_table :region_coverages
  end
end
