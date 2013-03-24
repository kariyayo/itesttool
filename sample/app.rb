# -*- coding: utf-8 -*-
require 'sinatra'

get '/index' do
  'Hello world!'
end

get '/index.json' do
<<-JSON
{
  "team": "ABC",
  "members": [
    {"name": "Ichiro", "age": 32, "hobbies": ["釣り", "登山"]},
    {"name": "Jiro",   "age": 22, "hobbies": ["映画鑑賞", "読書"]},
    {"name": "Saburo", "age": 12, "hobbies": ["サッカー"]}
  ]
}
JSON
end

get '/index.xml' do
<<-XML
<root>
  <team>ABC</team>
  <members>
    <member order="1">
      <name>Ichiro</name>
      <age>32</age>
      <hobby>釣り</hobby>
      <hobby>登山</hobby>
    </member>
    <member order="2">
      <name>Jiro</name>
      <age>22</age>
      <hobby>映画鑑賞</hobby>
      <hobby>読書</hobby>
    </member>
    <member order="3">
      <name>Saburo</name>
      <age>12</age>
      <hobby>サッカー</hobby>
    </member>
  </members>
</root>
XML
end

get '/index.html' do
<<-HTML
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <title>Page Title!</title>
</head>
<body>
  <h1 id="team">ABC</h1>
  <ol id="members">
    <li class="member">
      <dl>
        <dt>name</dt><dd class="name">Ichiro</dd>
        <dt>age</dt><dd class="age">32</dd>
        <dt>hobby</dt>
        <dd>
          <ul>
            <li>釣り</li><li>登山</li>
          </ul>
        </dd>
      </dl>
    </li>
    <li class="member">
      <dl>
        <dt>name</dt><dd class="name">Jiro</dd>
        <dt>age</dt><dd class="age">22</dd>
        <dt>hobby</dt>
        <dd>
          <ul>
            <li>映画鑑賞</li><li>読書</li>
          </ul>
        </dd>
      </dl>
    </li>
    <li class="member">
      <dl>
        <dt>name</dt><dd class="name">Saburo</dd>
        <dt>age</dt><dd class="age">12</dd>
        <dt>hobby</dt>
        <dd>
          <ul>
            <li>サッカー</li>
          </ul>
        </dd>
      </dl>
    </li>
  </ol>
</body>
</html>
HTML
end

post '/login' do
<<-JSON
{
  "nickname": "#{params[:nickname]}",
  "password": "#{params[:password]}"
}
JSON
end

post '/echo' do
  request.body.string
end

put '/echo' do
  request.body.string
end

delete '/echo' do
  request.body.string
end

