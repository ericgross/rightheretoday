Rails.application.routes.draw do
  get 'nearby/index'

  get 'messaging' => 'messaging#send_message'

  root to:'nearby#index'
end
