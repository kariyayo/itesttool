require 'sinatra'

get '/index' do
  'Hello world!'
end

get '/index.json' do
  '{ "name": "Taro", "msg": "Hello world!"}'
end
