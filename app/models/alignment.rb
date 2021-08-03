class Alignment  < ActiveRecord::Base
  belongs_to :alignment_set
  belongs_to :region
  #belongs_to :feature_type
  belongs_to :assembly


  def self.in_region(scaffold, start, last )
    return joins(region: :scaffold).where(["
      (
        regions.start BETWEEN :start and :last            OR 
        regions.end BETWEEN :start AND :last              OR 
        (regions.start < :start AND regions.end   > :last) OR
        (regions.end   < :start AND regions.start > :last)
      ) AND 
      scaffolds.name = :scaffold" , 
      {start: start, last: last, scaffold: scaffold}])

  end

  def corresponding()
    return Alignment.where( 
      {
        align_id: self.align_id,
        alignment_set_id:self.alignment_set_id
      }).where.not({
        id: self.id
      }).take
  end

  def <=>(other)
    return region.<=>(other.region)
  end

  def overlap(other)
    return region.overlap(other.overlap)
  end

  def to_s
    "#{region.to_s} (#{region.size}) #{orientation} #{assembly.name} #{alignment_set.name}"
  end

end
