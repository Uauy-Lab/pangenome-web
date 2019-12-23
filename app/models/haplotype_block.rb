class HaplotypeBlock < ApplicationRecord
  belongs_to :region
  has_one :scaffold, through: :region
  belongs_to :assembly
  belongs_to :haplotype_set
  belongs_to :first_feature, class_name: :Feature, foreign_key: :first_feature, optional: true
  belongs_to :last_feature,  class_name: :Feature, foreign_key: :last_feature, optional: true
  belongs_to :reference_assembly,  class_name: :Assembly, foreign_key: :reference_assembly
end
