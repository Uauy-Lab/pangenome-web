class HaplotypeBlock < ApplicationRecord
  belongs_to :region
  belongs_to :assembly
  belongs_to :first_feature, class_name: :Feature, foreign_key: :feature_id
  belongs_to :last_feature, class_name: :Feature, foreign_key: :feature_id
end
