# -*- coding: utf-8 -*-
require './lib/itesttool'

describe 'send GET request' do
  context 'no query parameter' do
    _when { get 'http://localhost:4567/index', as_text }
    _then {
      # status code
      res.code.should eq '200'

      # response body
      res.body.should eq 'Hello world!'
    }
  end

  context 'with query parameter' do
    context 'use "?"' do
      _when { get 'http://localhost:4567/index?night=true', as_text }
      _then {
        res.code.should eq '200'
        res.body.should eq 'Good night!'
      }
    end
    context 'use "query" helper method"' do
      _when {
        get 'http://localhost:4567/index',
            as_text,
            query('night'  => 'true',
                  'times' => 3)}
      _then {
        res.code.should eq '200'
        res.body.should eq 'Good night!Good night!Good night!'
      }
    end
  end
end

describe 'expectation for returned JSON' do
  _when { get 'http://localhost:4567/index.json', as_json }
  _then {
    res.code.should eq '200'

    # json schema
    res.body.should eq_schema_of 'json_schema/hello.json'

    # using jsonpath
    res['$.team'].should eq ['ABC']
    res['$.members..name'].should eq ['Ichiro', 'Jiro', 'Saburo']
    res['$.members..hobbies'].should eq [['釣り', '登山'], ['映画鑑賞', '読書'], ['サッカー']]
    res['$.members..age'].should include 32
    res['$.members[::]'].should have(3).items
    res['$.members[::]'].should have_at_most(3).items
    res['$.members[::]'].should have_at_least(1).items
    res['$.members..name'].should all be_a_kind_of String
    res['$.members..age'].should all be_a_kind_of Integer
    res['$.members..age'].should all be > 11
    res['$.members..age'].should all be >= 12
    res['$.members..age'].should all be < 33
    res['$.members..age'].should all be <= 32
    res['$.members..age'].should be_sorted :desc
  }
end

describe 'expectation for returned XML' do
  _when { get 'http://localhost:4567/index.xml', as_xml }
  _then {
    res.code.should eq '200'

    # using xpath
    res['/root/team/text()'].should eq ['ABC']
    res['/root/members//name/text()'].should eq ['Ichiro', 'Jiro', 'Saburo']
    res['/root/members//age/text()'].should include '32'
    res['/root/members/*'].should have(3).items
    res['/root/members/*'].should have_at_most(3).items
    res['/root/members/*'].should have_at_least(1).items
    res['/root/members//age/text()'].should all be > "11"
    res.select('/root/members//age/text()') do |member_ages|
      member_ages.should all be >= "10"
      member_ages.should all be < "33"
      member_ages.should all be <= "32"
      member_ages.should be_sorted :desc
    end
    res['/root/members/member/@order'].should be_sorted :asc
  }
end

describe 'expectation for returned HTML' do
  _when { get 'http://localhost:4567/index.html', as_html }
  _then {
    res.code.should eq '200'

    # using CSS selector
    res['title'].should eq ['Page Title!']
    res['h1#team'].should eq ['ABC']
    res['.member dd.name'].should eq ['Ichiro', 'Jiro', 'Saburo']
    res['.member dd.age'].should include '32'
    res['.member'].should have(3).items
    res['.member'].should have_at_most(3).items
    res['.member'].should have_at_least(1).items
    res['.member dd.age'].should all be > "11"
    member_ages = res['.member dd.age']
      member_ages.should all be >= "10"
      member_ages.should all be < "33"
      member_ages.should all be <= "32"
      member_ages.should be_sorted :desc
  }
end

describe 'set request headers' do
  _given {
    headers 'referer' => 'http://local.example.com',
            'user_agent' => 'itesttool'
  }
  _when { get 'http://localhost:4567/index.html', as_html }
  _then {
    res.code.should eq '200'
  }
end

describe 'POST form data' do
  _when {
    post 'http://localhost:4567/login',
         body_as_form('nickname' => 'admin',
                      'password' => 'pass'),
         res_is_json
  }
  _then {
    res.code.should eq '200'
    res['$.nickname'].should eq ['admin']
  }
end

describe 'POST json' do
  context 'specified json by "body()"' do
    _when {
      post 'http://localhost:4567/echo',
           body('{"name":"Shiro","age":2}'),
           res_is_json
    }
    _then {
      res.code.should eq '200'
      res.body.should eq '{"name":"Shiro","age":2}'
    }
  end
  context 'specified json by "body_as_json()"' do
    _when {
      post 'http://localhost:4567/echo',
           body_as_json('name' => 'Shiro',
                        'age' => 2),
           res_is_json
    }
    _then {
      res.code.should eq '200'
      res.body.should eq '{"name":"Shiro","age":2}'
    }
  end
end

describe 'PUT json' do
  _when {
    put 'http://localhost:4567/echo',
        body_as_json('name' => 'Shiro',
                     'age' => 2),
        res_is_json
  }
  _then {
    res.code.should eq '200'
    res.body.should eq '{"name":"Shiro","age":2}'
  }
end

describe 'Status 200 check' do
  status_check [
      'http://localhost:4567/index.json',
      'http://localhost:4567/index'
  ]
end

