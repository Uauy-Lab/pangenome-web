class KmerAnalysis < ApplicationRecord
  belongs_to :line
  belongs_to :library
  belongs_to :assembly
  has_and_belongs_to_many :score_type
end
