SELECT  a.*, features.name, regions.start, regions.end 
FROM (SELECT features.id as asm_feature_id, `features`.name as asm_gene, scaffolds.name as asm_chr, regions.start as asm_start, regions.end as asm_end
	FROM `regions`
	JOIN `scaffolds` on `regions`.`scaffold_id` = `scaffolds`.`id`
	JOIN `assemblies` on `scaffolds`.`assembly_id` = `assemblies`.`id`
	join `features` on `regions`.`id` = `features`.`region_id`
	join feature_types on feature_types.id = features.feature_type_id
	WHERE assemblies.name  = 'mace'
	AND regions.start >= 384840493
	and regions.end   <= 393124982
	and scaffolds.name = 'chr1D__mac'
	and feature_types.name = 'gene' ) as a
LEFT JOIN feature_mappings on feature_mappings.other_feature = a.asm_feature_id
LEFT JOIN features on features.id = feature_mappings.feature_id
LEFT JOIN regions on regions.id = features.region_id
ORDER BY asm_gene;