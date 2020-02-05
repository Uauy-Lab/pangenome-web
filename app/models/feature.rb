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

  def start
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

  def overlap(other)
    ret = other.chr == self.chr
    ret &= (other.start.between?(self.start, self.to) or other.to.between?(self.start, self.to) )
    ret
  end
end
