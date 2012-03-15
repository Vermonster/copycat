Rails.application.routes.draw do
  resources :copycat_translations, :only => [:index, :edit, :update] do
    get 'upload', :on => :collection
    post 'import_yaml', :on => :collection
  end
end
