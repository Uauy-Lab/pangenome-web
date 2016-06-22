Rails.application.routes.draw do
  
  root 'wellcome#default'
  get 'wellcome/search_gene'
  
  post 'deletions/query_for_lines'
  get 'deletions/query_for_lines'
  
  resources :search  do
    collection do
      get 'list'
      post 'list'
      post 'redirect'
    end
  end

end
