class Region < ActiveRecord::Base
  belongs_to :scaffold

  def to_s
  	scaffold.name + ":" + self.first.to_s + "-" + self.last.to_s + ":" + self.orientation
  end

  def size
  	self.last - self.first
  end

  def overlap(other, flank: 0)
    ret = other.scaffold == self.scaffold

    ret &= (
      other.first.between?((self.first  - flank), (self.last + flank))  or 
      other.last.between?((self.first  - flank), (self.last + flank))  or 
      self.first.between?((other.first + flank), (other.last - flank)) or 
      self.last.between?((other.first + flank), (other.last - flank)) )
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

  def round(ndigits, save: false )     
    ndigits =  10.0 ** ndigits.abs

    #(48/100.0).ceil * 100
    new_start = (self.start / ndigits).round.to_i * ndigits.to_i
    new_end   = (self.end   / ndigits).round.to_i * ndigits.to_i
    region = nil
    if save
      region =  Region.find_or_create_by(scaffold: self.scaffold, start: new_start, end: new_end )
    else
      region = self.copy
      region.start = new_start
      region.end = new_end

    end
    return region
  end

  def copy
    region = Region.new
    region.start = self.start
    region.end   =  self.end
    region.scaffold = self.scaffold
    return region
  end

  def merge(other, flank: 0)
    region = self.copy
    raise "Regions must overlap (#{self.to_s} - #{other.to_s})" unless self.overlap(other, flank: flank)
    raise "Regions must have the same orientation" unless self.orientation == other.orientation
    puts "Merging: #{region.to_s} to #{other.to_s}"
    if region.orientation == "+"
      region.start = region.start < other.start ? region.start : other.start
      region.end   = region.end   > other.end   ? region.end : other.end
    elsif region.orientation == "-"
      region.start = region.start > other.start ? region.start : other.start
      region.end   = region.end   <   other.end ? region.end : other.end
    end
    puts "Merged: #{region.to_s}"

    return region

  end

end
