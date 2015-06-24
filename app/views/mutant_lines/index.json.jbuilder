json.array!(@mutant_lines) do |mutant_line|
  json.extract! mutant_line, :id, :name, :description
  json.url mutant_line_url(mutant_line, format: :json)
end
