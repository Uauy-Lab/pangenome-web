class Snp < ActiveRecord::Base
  belongs_to :scaffold
  has_many :primers
  #belongs_to :species
end
