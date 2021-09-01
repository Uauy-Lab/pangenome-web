#require 'sequenceserver'
require "#{Rails.root}/lib/links.rb"  

Rails.application.routes.draw do
  
  get 'haplotype_set/index'
  # get 'haplotype_set/:species/chr/:chr_name',        to: 'haplotype_set#show'
  # get 'haplotype_set/show/:name/chr/:chr_name',      to: 'haplotype_set#show'
  # get 'haplotype_set/show/:name/:asm/chr/:chr_name', to: 'haplotype_set#show'
  root 'wellcome#default'
  get  'wellcome/search_gene'

  get  ':species/haplotype/:chr_name',        to: 'haplotype_set#show'
  get  ':species/haplotype/:chr_name/:hap_set',        to: 'haplotype_set#show_single'
  post 'deletions/query_for_lines'
  get  'deletions/query_for_lines'

  get  'species', to: 'application#species'
  get  ':page' => 'markdown#show'
  
  get  ':species/coordinates/:chr_name/window/:window_size', to: 'assemblies#coordinate_mappig'

  get  ':species/kmer_analysis/:analysis/ref/:reference/sample/:sample/chr/:chr_name', to: 'kmer_score#get_kmer_scores'
  get  ':species/ibspy/:chr_name', to: 'kmer_score#show'

  get  ':species/feature/:type/:chromosome/autocomplete/:query', to: "search#feature"
  get  ':species/feature/:type/:chromosome/coordinates/:query',  to: "search#coordinates"
  
  get ':species/mapping/:align_set_id/chr/:chr/start/:start/end/:end', to: "mapping#coordinate_mapping"
  get ':species/mapping/:align_set_id', to:"mapping#zoomed"

  resources :search  do
    collection do
      post 'redirect'
      get  'feature'
      get  'any'
    end
  end

  #Lines to make sequenceserver run.
  if @sequenceserver
    begin
      SequenceServer.init
      mount SequenceServer, at: "sequenceserver"
    rescue e
      $stderr.puts "Error loading sequence server"
      $tderr.puts e.to_s
    end
  end
end
