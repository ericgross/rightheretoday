Rails.application.routes.draw do
  get 'nearby/index'

  root to:'nearby#index'
end
