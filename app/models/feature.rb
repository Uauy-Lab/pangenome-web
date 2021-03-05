class Feature < ActiveRecord::Base
  belongs_to :region
  belongs_to :feature_type
  belongs_to :biotype, optional: true
  belongs_to :parent, :class_name => "Feature", :foreign_key => "parent_id" , optional: true

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

  def self.find_by_features_in_block(block, type: 'gene')
    query = "SELECT `features`.*
    FROM `regions`
    JOIN `scaffolds` on `regions`.`scaffold_id` = `scaffolds`.`id`
    JOIN `assemblies` on `scaffolds`.`assembly_id` = `assemblies`.`id`
    join `features` on `regions`.`id` = `features`.`region_id`
    join feature_types on feature_types.id = features.feature_type_id
    WHERE assemblies.name  = ?
    AND regions.start >= ?
    and regions.end <= ?
    and scaffolds.name = ?
    and feature_types.name = ? ;"
    Feature.find_by_sql([query, block.reference, block.start, block.end, block.chromosome, type] )
  end

  def self.count_features_in_block(block, type: 'gene')
    query = "SELECT count(*) as count
    FROM `regions`
    JOIN `scaffolds` on `regions`.`scaffold_id` = `scaffolds`.`id`
    JOIN `assemblies` on `scaffolds`.`assembly_id` = `assemblies`.`id`
    join `features` on `regions`.`id` = `features`.`region_id`
    join feature_types on feature_types.id = features.feature_type_id
    WHERE assemblies.name  = ?
    AND regions.start >= ?
    and regions.end <= ?
    and scaffolds.name = ?
    and feature_types.name = ? ;"
    Feature.find_by_sql([query, block.reference, block.start, block.end, block.chromosome, type] ).first
  end

  def self.autocomplete_chromosome( chromosome_id, type:'gene', limit: 30)
    query = "SELECT features.* FROM features
JOIN feature_types ON feature_types.id  = features.feature_type_id
JOIN regions ON features.region_id = regions.id
JOIN scaffolds ON regions.scaffold_id = scaffolds.id
JOIN chromosomes ON chromosomes.id = scaffolds.chromosome
WHERE feature_types.name = ?
AND chromosomes.id=  ?
LIMIT ?"
    Feature.find_by_sql([query, type, chromosome_id, limit ])
  end

end
