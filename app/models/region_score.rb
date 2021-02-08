class RegionScore < ApplicationRecord
  belongs_to :kmer_analysis
  belongs_to :region
end
