class Snp < ActiveRecord::Base
  belongs_to :scaffold
  has_many :mutations 
  has_many :primers
end
