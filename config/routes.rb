Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/redirect', to: 'access#redirect', as: 'redirect'
  get '/callback', to: 'access#callback', as: 'callback'
  get '/calendars', to: 'access#calendars', as: 'calendars'

end
