class Region < ActiveRecord::Base
  belongs_to :scaffold

  def to_s
  	"#{scaffold.name}:#{self.first.to_s}-#{self.last.to_s}:#{self.orientation}(#{self.size})" 
  end

  def simple_s
    "#{scaffold.name}:#{self.start.to_s}-#{self.end.to_s}"
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
    return self.first.to_i <=> other.first.to_i if other.first != self.first
    return self.last.to_i  <=> other.last.to_i  if other.last  != self.last
    return self.orientation <=> other.orientation
  end

  def round(ndigits, save: false )     
    ndigits =  10.0 ** ndigits.abs
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
    raise "Regions must have the same orientation (#{self.to_s} - #{other.to_s}) "  unless self.orientation == other.orientation
    #puts "Merging: #{region.to_s} to #{other.to_s}"
    if region.orientation == "+"
      region.start = region.start < other.start ? region.start : other.start
      region.end   = region.end   > other.end   ? region.end : other.end
    elsif region.orientation == "-"
      region.start = region.start > other.start ? region.start : other.start
      region.end   = region.end   <   other.end ? region.end : other.end
    end
    return region
  end

  #returns the difference on the first and last, that can be used to calculate how much this changed. 
  def crop!(scaffold, first, last)
    raise "Wrong scaffold" unless scaffold == self.name
    
    original_first = self.first 
    original_last  = self.last

    if orientation == "+"
      self.start = self.start < first ? first :  self.start 
      self.end   = self.end   > last  ? last  :  self.end   
      return [ self.start - original_first , original_last - self.end ]   
    else
      self.start = self.start > last  ?  last  : self.start 
      self.end   = self.end   < first ?  first : self.end   
      return [ original_last - self.start, self.end - original_first ]
    end
  end

  def delta_crop!(delta_start, delta_end)
    raise "Both deltas must be positives (#{self.to_s} #{delta_start} #{delta_end} )" if delta_start < 0 or delta_end < 0
    #puts "Delta: #{self.to_s} #{delta_start} #{delta_end}"
    if orientation == "+"
      self.start += delta_start
      self.end   -= delta_end 
    else
      self.end   += delta_start
      self.start -= delta_end
    end
  end

  def reverse!
    s = self.start
    e = self.end 
    self.start = e
    self.end   = s
  end

  def tsv
    "#{self.name}\t#{self.start}\t#{self.end}"
  end

  def self.find_for_save(scaffold, start, last)
    scaff  = Scaffold.cached_from_name(scaffold)
		throw "Unable to find #{scaff} " if scaff.nil?
		Region.find_or_create_by(scaffold: scaff, start: start, end: last )
  end

  def self.parse_and_find(str)
    arr = str.split(":")
    arr2 = arr[1].split("-")
    Region.find_for_save(arr[0], arr2[0], arr2[1])
  end
end
