class ScaffoldMap < ActiveRecord::Base
  belongs_to :scaffold
  belongs_to :chromosome
  belongs_to :genetic_map
end
