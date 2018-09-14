Rails.application.routes.draw do
  root 'calendars#authorize'
  get '/authorize', to: 'calendars#authorize', as: 'authorize'
  get '/callback', to: 'calendars#callback', as: 'callback'
  get '/calendars', to: 'calendars#new', as: 'calendars'
  post '/calendars/create', to: 'calendars#create'
end
