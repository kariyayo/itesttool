require 'sinatra'

get '/index' do
  'Hello world!'
end

get '/index.json' do
  <<-JSON
  {
    "team": "ABC",
    "members": [
      {"name": "Ichiro", "age": 32},
      {"name": "Jiro",   "age": 22},
      {"name": "Saburo", "age": 12}
    ]
  }
  JSON
end
