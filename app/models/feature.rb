class Feature < ActiveRecord::Base
  belongs_to :region
  belongs_to :feature_type
  belongs_to :biotype
  belongs_to :parent, :class_name => "Feature", :foreign_key => "parent_id" 
end
