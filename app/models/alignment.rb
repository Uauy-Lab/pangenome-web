class Alignment  < ActiveRecord::Base
  belongs_to :alignment_set
  belongs_to :region
  #belongs_to :feature_type
  belongs_to :assembly
end
