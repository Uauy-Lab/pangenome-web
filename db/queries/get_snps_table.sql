SELECT DISTINCT
	snps.id as snp_id,
	scaffolds.name as scaffold, 
	chromosomes.name as chr, 
	`lines`.name as line,
	snps.position as position,
	scaffold_mappings.other_coordinate as chr_position, 
	snps.ref as ref, 
	snps.wt as wt, 
	snps.alt as alt,
	mutations.het_hom as het_hom,
	mutations.wt_cov as wt_cv,
	mutations.mut_cov as mut_cov, 
	features.name as gene, 
	effect_types.name as effect, 
	effects.cdna_position as cdna_position, 
	effects.cds_position as cds_position, 
	effects.amino_acids as amino_acids,
	effects.codons as codons, 
	effects.sift_score as sift,
	primer_types.name  as primer_type, 
	primers.orientation as primer_orientation, 
	primers.wt as wt_primer, 
	primers.alt as at_primer, 
	primers.common as common_primer
FROM snps
JOIN scaffolds ON scaffolds.id = snps.scaffold_id
JOIN scaffold_mappings ON scaffold_mappings.scaffold_id = snps.scaffold_id AND scaffold_mappings.coordinate = snps.position
LEFT JOIN chromosomes on scaffolds.chromosome = chromosomes.id
LEFT JOIN mutations on mutations.SNP_id = snps.id
LEFT JOIN libraries on mutations.library_id = libraries.id
LEFT JOIN `lines` on libraries.line_id  = `lines`.id
LEFT JOIN effects on effects.snp_id = snps.id
LEFT JOIN effect_types on effect_types.id = effects.effect_type_id
LEFT JOIN features on effects.feature_id = features.id
LEFT JOIN primers on primers.snp_id = snps.id
LEFT JOIN primer_types on primer_types.id = primers.primer_type_id;
