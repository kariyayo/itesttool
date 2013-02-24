require './lib/itesttools'

describe "Access to /index" do
  _when  { @res = get "http://localhost:4567/index" }

  _then  { @res.should be_status "200" }
  _and   { @res.body.should eq "Hello world!" }
end

describe "Access to /index.json" do
  _when  { @res = get "http://localhost:4567/index.json" }

  _then  { @res.should be_status "200" }
  _and   { @res.body.should eq_schema_of "json_schema.json" }
end

