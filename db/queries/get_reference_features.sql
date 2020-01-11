
select features.*
from feature_mappings 
join feature_mapping_sets on feature_mappings.feature_mapping_set_id = feature_mapping_sets.id
join features on feature_mappings.feature_id = features.id
where other_feature in (
	SELECT `features`.id  
   	FROM `regions`
	JOIN `scaffolds` on `regions`.`scaffold_id` = `scaffolds`.`id`
	JOIN `assemblies` on `scaffolds`.`assembly_id` = `assemblies`.`id`
	join `features` on `regions`.`id` = `features`.`region_id`
	join feature_types on feature_types.id = features.feature_type_id
	WHERE `assemblies`.name  = "arinalrfor"
	AND regions.`start` >= 25000000
	and regions.`end` <= 30000000
	and scaffolds.`name` = 'chr3D__ari'
	and feature_types.`name` = 'gene'
)
ORDER BY features.name;