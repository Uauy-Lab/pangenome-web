module FeatureHelper
	 @@features_in_asm = false
	def self.find_features_in_assembly(assembly, feature_type)
		@@features_in_asm = Hash.new unless @@features_in_asm
		name = "#{assembly}_#{feature_type}"
    	return @@features_in_asm[name] if @@features_in_asm[name] 
		query = "SELECT 
		features.*
		FROM assemblies 
		JOIN scaffolds  on scaffolds.assembly_id = assemblies.id
		JOIN regions on regions.scaffold_id = scaffolds.id 
		JOIN features on features.region_id = regions.id
		JOIN feature_types on features.feature_type_id = feature_types.id
		WHERE  feature_types.name = ? 
		AND assemblies.name = ?" ;

		ret = Hash.new

		Feature.find_by_sql([query, feature_type, assembly]).each do |f|
			ret[f.name] = f[:region_id]
		end
		@@features_in_asm[name] = ret
		@@features_in_asm[name]
	end



end
