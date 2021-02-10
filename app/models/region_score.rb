class RegionScore < ApplicationRecord
  belongs_to :score_type, :autosave => true, :foreign_key => "score_types_id" 
  belongs_to :region, :autosave => true

  def self.add(region, type, value)
  	#puts type.inspect
  	mult = 1/(10 ** type.mantisa)
  	#puts "Inserting value #{mult} #{value}"
  	value = value * mult
  	#puts value
  	rs = RegionScore.new
  	rs.score_type = type
  	rs.region     = region
  	rs.value      = value.to_i
  	rs.save!
  	rs
  end
end
