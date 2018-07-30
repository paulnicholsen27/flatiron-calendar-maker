Rails.application.routes.draw do
  root 'calendars#new'
  get '/redirect', to: 'calendars#redirect', as: 'redirect'
  get '/callback', to: 'calendars#callback', as: 'callback'
  get '/calendars', to: 'calendars#list', as: 'calendars'
  post '/calendars/create', to: 'calendars#create'
end
