class AlignMapping < ApplicationRecord
  belongs_to :region
  belongs_to :align_mapping_set
  belongs_to :mapped_block, class_name: :Region, foreign_key: :mapped_block_id
end
