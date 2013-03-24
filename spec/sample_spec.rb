require './lib/itesttool'

describe 'send GET request' do
  _when { get 'http://localhost:4567/index' }
  _then {
    # status code
    res.code.should eq '200'

    # response body
    res.body.should eq 'Hello world!'
  }
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
    res['$.members..age'].should include 32
    res['$.members[::]'].should have(3).items
    res['$.members[::]'].should have_at_most(3).items
    res['$.members[::]'].should have_at_least(1).items
    res['$.members..name'].should all_be_type_of :string
    res['$.members..age'].should all_be_type_of :integer
    res['$.members..age'].should all_be_gt 11
    res['$.members..age'].should all_be_gt_eq 12
    res['$.members..age'].should all_be_lt 33
    res['$.members..age'].should all_be_lt_eq 32
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
    res['/root/members//age/text()'].should all_be_gt 11
    member_ages = res['/root/members//age/text()']
      member_ages.should all_be_gt_eq 10
      member_ages.should all_be_lt 33
      member_ages.should all_be_lt_eq 32
      member_ages.should be_sorted :desc
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
    res['.member dd.age'].should all_be_gt 11
    member_ages = res['.member dd.age']
      member_ages.should all_be_gt_eq 10
      member_ages.should all_be_lt 33
      member_ages.should all_be_lt_eq 32
      member_ages.should be_sorted :desc
  }
end

describe 'set request headers' do
  context 'specified request headers in argument of "get()"' do
    _when { get 'http://localhost:4567/index.html', as_html, 'referer' => 'http://local.example.com', 'user_agent' => 'itesttool' }
    _then {
      res.code.should eq '200'
    }
  end
  context 'specified request headers in "_given"' do
    _given {
      headers 'referer' => 'http://local.example.com',
              'user_agent' => 'itesttool'
    }
    _when { get 'http://localhost:4567/index.html', as_html }
    _then {
      res.code.should eq '200'
    }
  end
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

describe 'Status 200 check' do
  status_check [
      'http://localhost:4567/index.json',
      'http://localhost:4567/index'
  ]
end

