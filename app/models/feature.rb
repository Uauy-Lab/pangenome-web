class Feature < ActiveRecord::Base
  belongs_to :region
  belongs_to :feature_type
  belongs_to :biotype
  belongs_to :parent, :class_name => "Feature", :foreign_key => "parent_id" 

  def chr
  	region.scaffold.name
  end

  def from
  	region.start
  end

  def to
  	region.end
  end

  def to_r
  	"#{self.chr}:#{from}-#{to}"
  end

  def asm
  	region.scaffold.assembly
  end

  def <=>(other)
    self.name <=> other.name
  end
end
