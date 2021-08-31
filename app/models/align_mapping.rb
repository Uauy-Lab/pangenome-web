class AlignMapping < ApplicationRecord
  belongs_to :region
  belongs_to :align_mapping_set
  belongs_to :mapped_block, class_name: :Region, foreign_key: :mapped_block_id

   def self.in_region(scaffold, start, last, mapping_set )
    return joins(:region).where(["
      (
        regions.start BETWEEN :start and :last            OR 
        regions.end BETWEEN :start AND :last              OR 
        (regions.start < :start AND regions.end   > :last) OR
        (regions.end   < :start AND regions.start > :last)
      ) AND 
      regions.scaffold_id = :scaffold
      AND
      align_mappings.align_mapping_set_id = :mapping_set
      " , 
      {start: start, last: last, scaffold: scaffold.id, mapping_set: mapping_set.id}])

  end


end
