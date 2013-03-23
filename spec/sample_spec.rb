require './lib/itesttool'

describe "Access to /index" do
  _when { get "http://localhost:4567/index" }
  _then {
    res.code.should eq "200"
    res.body.should eq "Hello world!"
  }
end

describe "Access to /index.json" do
  _when { get "http://localhost:4567/index.json", as_json }
  _then {
    # status code
    res.code.should eq "200"

    # json schema
    res.body.should eq_schema_of "json_schema/hello.json"

    # using jsonpath
    res["$.team"].should eq ["ABC"]
    res["$.members..name"].should eq ["Ichiro", "Jiro", "Saburo"]
    res["$.members..age"].should include 32
    res["$.members[::]"].should have(3).items
    res["$.members[::]"].should have_at_most(3).items
    res["$.members[::]"].should have_at_least(1).items
    res["$.members..name"].should all_be_type_of :string
    res["$.members..age"].should all_be_type_of :integer
    res["$.members..age"].should all_be_gt 11
    res["$.members..age"].should all_be_gt_eq 12
    res["$.members..age"].should all_be_lt 33
    res["$.members..age"].should all_be_lt_eq 32
    res["$.members..age"].should be_sorted :desc
  }
end

describe "Access to /index.xml" do
  _when { get "http://localhost:4567/index.xml", as_xml }
  _then {
    # status code
    res.code.should eq "200"

    # using xpath
    res["/root/team/text()"].should eq ["ABC"]
    res["/root/members//name/text()"].should eq ["Ichiro", "Jiro", "Saburo"]
    res["/root/members//age/text()"].should include "32"
    res["/root/members/*"].should have(3).items
    res["/root/members/*"].should have_at_most(3).items
    res["/root/members/*"].should have_at_least(1).items
    res["/root/members//age/text()"].should all_be_gt 11
    member_ages = res["/root/members//age/text()"]
    member_ages.should all_be_gt_eq 10
    member_ages.should all_be_lt 33
    member_ages.should all_be_lt_eq 32
    member_ages.should be_sorted :desc
    res["/root/members/member/@order"].should be_sorted :asc
  }
end

describe "Access to /index.html" do
  _when { get "http://localhost:4567/index.html", as_html, "referer" => "http://local.example.com", "user_agent" => "itesttool" }
  _then {
    # status code
    res.code.should eq "200"

    # using xpath
    res["title"].should eq ["Page Title!"]
    res["h1#team"].should eq ["ABC"]
    res[".member dd.name"].should eq ["Ichiro", "Jiro", "Saburo"]
    res[".member dd.age"].should include "32"
    res[".member"].should have(3).items
    res[".member"].should have_at_most(3).items
    res[".member"].should have_at_least(1).items
    res[".member dd.age"].should all_be_gt 11
    member_ages = res[".member dd.age"]
    member_ages.should all_be_gt_eq 10
    member_ages.should all_be_lt 33
    member_ages.should all_be_lt_eq 32
    member_ages.should be_sorted :desc
  }
end

describe "Status 200 check" do
  status_check [
      'http://localhost:4567/index.json',
      'http://localhost:4567/index'
  ]
end

describe "Login" do
  _given {
    headers "referer" => "http://local.example.com",
            "user_agent" => "itesttool"
  }
  _when {
    post "http://localhost:4567/login",
      {
        "nickname" => "admin",
        "password" => "pass"
      },
      res_as_json
  }
  _then {
    res.code.should eq "200"
    res["$.nickname"].should eq ["admin"]
  }
end

