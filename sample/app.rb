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
