class Region < ActiveRecord::Base
  belongs_to :scaffold

  def to_s
  	scaffold.name + ":" + self.start.to_s + "-" + self.end.to_s
  end

  def size
  	self.end - self.start
  end

  def overlap(other)
    ret = other.scaffold == self.scaffold
    ret &= (other.start.between?(self.start, self.to) or other.to.between?(self.start, self.to) )
    ret
  end

  def <=>(other)
    return self.name  <=> other.name  if other.name  != self.name
    return self.start <=> other.start if other.start != self.start
    return self.end   <=> other.end
  end

end
