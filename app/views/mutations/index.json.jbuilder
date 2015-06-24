json.array!(@mutations) do |mutation|
  json.extract! mutation, :id, :scaffold_id, :chromosome_id, :library, :mutant_line_id, :position, :ref_base, :wt_base, :alt_base, :het_hom, :wt_cov, :mut_cov, :confidence, :gene_id, :mutation_consequence_id, :cdna_position, :cds_position, :amino_acids, :codons, :sift_score
  json.url mutation_url(mutation, format: :json)
end
