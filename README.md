# itesttool

[![Build Status](https://travis-ci.org/bati11/itesttool.png?branch=master)](https://travis-ci.org/bati11/itesttool)

itesttool is Web API end-to-end test tool in RSpec.

```ruby
describe 'send GET request' do
  _given {
    headers 'referer' => 'http://local.example.com'
  }
  _when { get 'http://localhost:4567/index', as_json }
  _then {
    res.code.should eq '200'
    res.body.should eq_schema_of 'json_schema/hello.json'
    res['$.members..name'].should eq ['Ichiro', 'Jiro', 'Saburo']
  }
end
```


## Installation
Add this line to your application's Gemfile

```ruby
gem 'itesttool'
```

And then execute
```sh
$ bundle install --path vendor/bundle
```


# Usage
Require `itesttool`

```ruby
require 'itesttool'
```


## GET request
 * `_given` is setup phase. `_given` is alias of `before` in RSpec.
 * `_when` is execution phase. it send HTTP request to server.
 * `_then` is assertion phase. in `_then`block, HTTP response is set `res`. `res` is instance of Net::HTTPResponse.

```ruby
describe 'send GET request' do
  _given {
    headers 'referer' => 'http://local.example.com'
  }
  _when { get 'http://localhost:4567/index' }
  _then {
    res.code.should eq '200'
  }
end
```


## assert HTTP response
assert status code:
```ruby
res.code.should eq '200'
```

assert response body:
```ruby
res.body.should eq 'Hello world!'
```

If respons body is the JSON, XML, HTML, you can assert an element using JSONPath, XPath, CSS Selectors.  
About JSONPath and XPath, please refer to the site: [http://goessner.net/articles/JsonPath/](http://goessner.net/articles/JsonPath/)

For assert to the array, itesttool defines custom matchers.
  - `all`
  - `be_one_and`
  - `be_sorted`

```ruby
[2, 3].should all be > 1  # same next code: [2, 3].each do |x| x.should be > 1 end

[2].should be_one_and be > 1     # success
[2, 3].should be_one_and be > 1  # failure

[1, 2, 3].should be_sorted :asc   # success
[1, 2, 3].should be_sorted :desc  # failure
[3, 2, 1].should be_sorted :desc  # success
```


### JSON
with JSONPath:
```ruby
res['$.team'].should eq ['ABC']
res['$.members..name'].should eq ['Ichiro', 'Jiro', 'Saburo']
res['$.members..age'].should include 32
res['$.members[::]'].should have(3).items
res['$.members[::]'].should have_at_most(3).items
res['$.members[::]'].should have_at_least(1).items
res['$.members..name'].should all be_kind_of String
res['$.members..age'].should all be_kind_of Integer
res['$.members..age'].should all be > 11
res['$.members..age'].should all be >= 12
res['$.members..age'].should all be < 33
res['$.members..age'].should all be <= 32
res['$.members..age'].should be_sorted :desc
```

with `select` helper method:
```ruby
res.select('$.members..age') do |ages|
  ages.should all be_kind_of Integer
  ages.should all be > 11
  ages.should all be >= 12
  ages.should all be < 33
  ages.should all be <= 32
  ages.should be_sorted :desc
end
```

you can assert with the JSON Schema.
```ruby
res.body.should eq_schema_of 'json_schema/hello.json'
```

json_schema/hello.js is JSON schema sample.

    {
      "type": "object",
      "properties": {
        "team": {"type": "string", "required": true},
        "members": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "name": {"type": "string", "required": true},
              "age":  {"type": "integer", "required": true}
            }
          }
        }
      }
    }



### XML
with XPath:
```ruby
res['/root/team/text()'].should eq ['ABC']
res['/root/members//name/text()'].should eq ['Ichiro', 'Jiro', 'Saburo']
res['/root/members//age/text()'].should include '32'
res['/root/members/*'].should have(3).items
res['/root/members/*'].should have_at_most(3).items
res['/root/members/*'].should have_at_least(1).items
res['/root/members//age/text()'].should all be > "11"
res.select('/root/members//age/text()') do |ages|
  ages.should all be >= "10"
  ages.should all be < "33"
  ages.should all be <= "32"
  ages.should be_sorted :desc
end
res['/root/members/member/@order'].should be_sorted :asc
```


### HTML
with CSS Selector:
```ruby
res['title'].should eq ['Page Title!']
res['h1#team'].should eq ['ABC']
res['.member dd.name'].should eq ['Ichiro', 'Jiro', 'Saburo']
res['.member dd.age'].should include '32'
res['.member'].should have(3).items
res['.member'].should have_at_most(3).items
res['.member'].should have_at_least(1).items
res['.member dd.age'].should all be > "11"
res.select('.member dd.age') do |ages|
  ages.should all be >= 10
  ages.should all be < 33
  ages.should all be <= 32
  ages.should be_sorted :desc
end
```


## query parameter
```ruby
_when { get 'http://localhost:4567/index?night=true', as_text }
_then {
  res.code.should eq '200'
}
```

with `query` helper function:
```ruby
_when {
  get 'http://localhost:4567/index',
      as_text,
      query('night' => 'true',
            'times' => 3)
}
_then {
  res.code.should eq '200'
}
```


## HTTP request header
```ruby
_given {
  headers 'referer' => 'http://local.example.com',
          'user_agent' => 'itesttool'
}
_when { get 'http://localhost:4567/index.html', as_html }
_then {
  res.code.should eq '200'
}
```


## POST request
```ruby
_when {
  post 'http://localhost:4567/login',
}
```

### application/x-www-form-urlencoded
use `body_as_form`:
```ruby
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
```


### application/json
use `body_as_json`:
```ruby
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
```

use string:
```ruby
_when {
  post 'http://localhost:4567/echo',
       body('{"name":"Shiro","age":2}'),
       res_is_json
}
_then {
  res.code.should eq '200'
  res.body.should eq '{"name":"Shiro","age":2}'
}
```


## PUT, DELETE request
same as a `post`. instead of use `put`, or `delete`.


# License
The MIT License. See LICENSE.txt

