Rails.application.routes.draw do
  resources :copycat_translations, :only => [:index, :edit, :update] do
    collection do
      get 'readme'
      get 'upload'
      post 'import_yaml'
      post 'change_locale'
      post 'search'
    end
  end
end
