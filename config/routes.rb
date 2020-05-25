Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/ping', to: 'ping#ping'

  scope :commands do
    post '/kitecam', to: 'commands#kitecam'
    post '/swimdb', to: 'commands#swimdb'
    post '/tides', to: 'commands#tides'
    post '/watertemp', to: 'commands#watertemp'
    post '/wind', to: 'commands#wind'
  end

end
