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
    "#{region.to_s} (#{region.size}) #{orientation} #{assembly.name} (#{self.pident}) #{alignment_set.name}"
  end

  def self.in_region_by_assembly(chr, start, last, assemblies:[])

    alns = Alignment.in_region(chr, start, last)
    ret = Hash.new() { |h, k|  h[k]  = [] }
    alns.sort.each do |aln|
      corresponding = aln.corresponding
      ret[corresponding.assembly.name].append(aln)
    end

    return ret
  end

  


end
