json.array!(@genes) do |gene|
  json.extract! gene, :id, :name, :cdna, :possition, :gene, :transcript, :geneSet
  json.url gene_url(gene, format: :json)
end
