require './lib/itesttool'

describe "Access to /index" do
  _when get "http://localhost:4567/index" do
    its(:code) { should eq "200" }
    its(:body) { should eq "Hello world!" }
  end
end

describe "Access to /index.json" do
  _when get "http://localhost:4567/index.json" do
    its("code") { should eq "200" }
    its("body") { should eq_schema_of "json_schema/hello.json" }
    its("body_as_json") {
      should include "name" => "Taro"
      should include "msg" => "Hello world!"
    }
  end
end

describe "Status 200 check" do
  status_check [
      'http://localhost:4567/index.json',
      'http://localhost:4567/index'
  ]
end

