class Region < ActiveRecord::Base
  belongs_to :scaffold

  def to_s
  	scaffold.name + ":" + self.first.to_s + "-" + self.last.to_s + ":" + self.orientation
  end

  def size
  	self.last - self.first
  end

  def overlap(other)
    ret = other.scaffold == self.scaffold
    ret &= (other.start.between?(self.start, self.to) or other.to.between?(self.start, self.to) )
    ret
  end

  def name
    scaffold.name
  end

  def orientation
    self.start <= self.end   ? "+" : "-" 
  end

  def first
    self.start <= self.end   ? self.start : self.end 
  end

  def last
    self.end   >= self.start ? self.end   : self.start
  end

  def <=>(other)
    return self.name  <=> other.name  if other.name  != self.name
    return self.first <=> other.first if other.first != self.first
    return self.last  <=> other.last  if other.last  != self.last
    return self.orientation <=> other.orientation
  end

end
