require 'sequenceserver'
require "#{Rails.root}/lib/links.rb"  

Rails.application.routes.draw do
  
  get 'haplotype_set/index'
  get 'haplotype_set/show/:name/chr/:chr_name', to: 'haplotype_set#show'
  get 'haplotype_set/show/:name/:asm/chr/:chr_name', to: 'haplotype_set#show'
  root 'wellcome#default'
  get 'wellcome/search_gene'
  
  
  post 'deletions/query_for_lines'
  get 'deletions/query_for_lines'
  
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
    SequenceServer.init
    mount SequenceServer, :at => "sequenceserver"
  end
end
