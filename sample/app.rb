require 'sinatra'

get '/index' do
  'Hello world!'
end

get '/index.json' do
  '{ "msg": "Hello world!"}'
end
