Rails.application.routes.draw do
  resources Copycat.route,
    :as => 'copycat_translations', 
    :controller => 'copycat_translations',
    :only => [:index, :edit, :update, :destroy] do
    collection do
      get 'help'
      get 'import_export'
      get 'download'
      post 'upload'
    end
  end
end
