require './lib/itesttool'

describe "Access to /index" do
  _when get "http://localhost:4567/index" do
    its(:code) { should eq "200" }
    its(:body) { should eq "Hello world!" }
  end
end

describe "Access to /index.json" do
  _when get "http://localhost:4567/index.json" do
    # status code
    its("code") { should eq "200" }

    # json schema
    its("body") { should eq_schema_of "json_schema/hello.json" }

    # key & value by jsonpath
    its(["$.team"]) { should eq ["ABC"] }
    its(["$.members..name"]) { should eq ["Ichiro", "Jiro", "Saburo"] }
    its(["$.members..age"]) { should include 32 }
    its(["$.members[::]"]) { should have(3).items }
    its(["$.members[::]"]) { should have_at_most(3).items }
    its(["$.members[::]"]) { should have_at_least(1).items }
    its(["$.members..name"]) { should be_type_of String }
    its(["$.members..age"]) { should be_type_of Integer }
  end
end

describe "Status 200 check" do
  status_check [
      'http://localhost:4567/index.json',
      'http://localhost:4567/index'
  ]
end

