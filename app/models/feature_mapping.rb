class FeatureMapping < ApplicationRecord
  belongs_to :assembly
  belongs_to :feature
  belongs_to :chromosome
  belongs_to :feature_mapping_set
  belongs_to :other_feature, class_name: :Feature, foreign_key: :other_feature
end
