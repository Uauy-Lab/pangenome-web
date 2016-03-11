SELECT 
	parent.name as mRNA, 
	libraries.name as library,
	lines.name as line,
	scaffolds.name  as scaffold
FROM features as exons
JOIN region_coverages on region_coverages.region_id = exons.region_id 
JOIN features as parent on exons.parent_id=parent.id
JOIN regions on regions.id = exons.region_id
JOIN libraries on region_coverages.library_id = libraries.id
JOIN scaffolds on regions.scaffold_id = scaffolds.id
JOIN deleted_scaffolds on  deleted_scaffolds.library_id = libraries.id and deleted_scaffolds.scaffold_id = scaffolds.id
JOIN `lines` on libraries.line_id = lines.id 
join feature_types on exons.feature_type_id = feature_types.id
WHERe feature_types.name = "exon"
GROUP BY libraries.name, scaffolds.name, parent.name, lines.name, feature_types.name
ORDER by parent.name;
