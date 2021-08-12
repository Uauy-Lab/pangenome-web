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

  def self.in_region_by_assembly(chr, first, last)
    alns = Alignment.in_region(chr, first, last)
    ret = Hash.new() { |h, k|  h[k]  = [] }
    alns.sort.each do |aln|
      corresponding = aln.corresponding
      next unless corresponding.assembly.is_pseudomolecule
      ret[corresponding.assembly.name].append(aln)
    end
    return ret
  end

  def self.in_region_eager(scaffold, start, last)
    scaff = Scaffold.cached_from_name(scaffold)
    query = "SELECT
r1.scaffold_id  as scaffold,
r1.`start` as `start`,
r1.`end`   as `end`,
r2.scaffold_id as scaffold_2,
r2.`start` as `start_2`,
r2.`end`   as `end_2`,
a2.assembly_id as asm
FROM
regions r1
JOIN `alignments` a1 ON a1.region_id = r1.id
JOIN alignments a2   ON a1.align_id = a2.align_id AND a1.alignment_set_id = a2.alignment_set_id and a1.id != a2.id
JOIN regions r2      ON a2.region_id = r2.id
WHERE 
(
  r1.start BETWEEN :start and :last            OR 
  r1.end BETWEEN :start AND :last              OR 
  (r1.start < :start AND r1.end   > :last) OR
  (r1.end   < :start AND r1.start > :last)
) AND 
r1.scaffold_id = :scaffold
ORDER BY 
  (CASE 
    WHEN r1.`start` < r1.`end` THEN r1.`start` 
    ELSE r1.`end`
  END) ASC,
  (CASE 
    WHEN r1.`start` < r1.`end` THEN r1.`end` 
    ELSE r1.`start`
  END) ASC

 ;
"
    Alignment.find_by_sql([query, {start: start, last: last, scaffold: scaff.id}] )
  end

  def self.in_region_by_assembly_eager(chr, first, last)
    alns = Alignment.in_region_eager(chr, first, last)
    ret = Hash.new() { |h, k|  h[k]  = [] }
    alns.each do |aln|
      asm = Assembly.cached_from_id(aln.asm)
      next unless asm.is_pseudomolecule
      r1 = Region.new
      r1.scaffold = Scaffold.cached_from_id(aln.scaffold)
      r1.start = aln.start
      r1.end   = aln.end

      r2 = Region.new
      r2.scaffold = Scaffold.cached_from_id(aln.scaffold_2)
      r2.start = aln.start_2
      r2.end   = aln.end_2
    
      ret[asm.name].append([r1,r2])

    end
    return ret
  end


end
