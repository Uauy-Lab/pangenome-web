require 'sequenceserver'
require "#{Rails.root}/lib/links.rb"  

Rails.application.routes.draw do
  
  get 'haplotype_set/index'
  #get 'haplotype_set/:species/chr/:chr_name',        to: 'haplotype_set#show'
  #get 'haplotype_set/show/:name/chr/:chr_name',      to: 'haplotype_set#show'
  #get 'haplotype_set/show/:name/:asm/chr/:chr_name', to: 'haplotype_set#show'
  root 'wellcome#default'
  get 'wellcome/search_gene'

  get ':species/haplotype/:chr_name',        to: 'haplotype_set#show'
  get ':species/haplotype/:chr_name/:hap_set',        to: 'haplotype_set#show_single'
  post 'deletions/query_for_lines'
  get 'deletions/query_for_lines'

  get 'species', to: 'application#species'
  get ':page' => 'markdown#show'
  
  get ':species/coordinates/:chr_name/window/:window_size', to: 'assemblies#coordinate_mappig'

  get ':species/kmer_analysis/:analysis/ref/:reference/sample/:sample/chr/:chr_name', to: 'kmer_score#get_kmer_scores'
  get ':species/ibspy/:chr_name', to: 'kmer_score#show'

  get ':species/feature/autocomplete/:type/:chromosome/:query', to: "search#feature"

  resources :search  do
    collection do
      get 'list'
      post 'list'
      post 'redirect'
      get 'autocomplete'
      get 'sequence'
    end
  end

#Lines to make sequenceserver run.
  if @sequenceserver
    begin
      SequenceServer.init
      mount SequenceServer, :at => "sequenceserver"
    rescue e
      $stderr.puts "Error loading sequence server"
      $tderr.puts e.to_s
    end
  end
end
