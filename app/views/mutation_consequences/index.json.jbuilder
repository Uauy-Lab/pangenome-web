json.array!(@mutation_consequences) do |mutation_consequence|
  json.extract! mutation_consequence, :id, :name, :description
  json.url mutation_consequence_url(mutation_consequence, format: :json)
end
