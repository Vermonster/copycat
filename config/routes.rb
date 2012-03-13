Rails.application.routes.draw do
  resources :copycat_translations, :only => [:index, :edit, :update] 
end
