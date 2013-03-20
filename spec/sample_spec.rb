require './lib/itesttool'

describe "Access to /index" do
  _when get "http://localhost:4567/index" do
    its(:code) { should eq "200" }
    its(:body) { should eq "Hello world!" }
  end
end

describe "Access to /index.json" do
  _when get "http://localhost:4567/index.json", :fotmat => "json" do
    # status code
    its("code") { should eq "200" }

    # json schema
    its("body") { should eq_schema_of "json_schema/hello.json" }

    # using jsonpath
    its(["$.team"]) { should eq ["ABC"] }
    its(["$.members..name"]) { should eq ["Ichiro", "Jiro", "Saburo"] }
    its(["$.members..age"]) { should include 32 }
    its(["$.members[::]"]) { should have(3).items }
    its(["$.members[::]"]) { should have_at_most(3).items }
    its(["$.members[::]"]) { should have_at_least(1).items }
    its(["$.members..name"]) { should all_be_type_of :string }
    its(["$.members..age"]) { should all_be_type_of :integer }
    its(["$.members..age"]) { should all_be_gt 11 }
    its(["$.members..age"]) { should all_be_gt_eq 12 }
    its(["$.members..age"]) { should all_be_lt 33 }
    its(["$.members..age"]) { should all_be_lt_eq 32 }
    its(["$.members..age"]) { should be_sorted :desc }
  end
end

describe "Access to /index.xml" do
  _when get "http://localhost:4567/index.xml", :format => "xml" do
    # status code
    its("code") { should eq "200" }

    # using xpath
    its(["/root/team/text()"]) { should eq ["ABC"] }
    its(["/root/members//name/text()"]) { should eq ["Ichiro", "Jiro", "Saburo"] }
    its(["/root/members//age/text()"]) { should include "32" }
    its(["/root/members/*"]) { should have(3).items }
    its(["/root/members/*"]) { should have_at_most(3).items }
    its(["/root/members/*"]) { should have_at_least(1).items }
    its(["/root/members//age/text()"]) { should all_be_gt 11 }
    its(["/root/members//age/text()"]) {
      should all_be_gt_eq 10
      should all_be_lt 33
      should all_be_lt_eq 32
      should be_sorted :desc
    }
    its(["/root/members/member/@order"]) { should be_sorted :asc }
  end
end

describe "Access to /index.html" do
  _when get "http://localhost:4567/index.html", :format => "html" do
    # status code
    its("code") { should eq "200" }

    # using xpath
    its(["title"]) { should eq ["Page Title!"] }
    its(["h1#team"]) { should eq ["ABC"] }
    its([".member dd.name"]) { should eq ["Ichiro", "Jiro", "Saburo"] }
    its([".member dd.age"]) { should include "32" }
    its([".member"]) { should have(3).items }
    its([".member"]) { should have_at_most(3).items }
    its([".member"]) { should have_at_least(1).items }
    its([".member dd.age"]) { should all_be_gt 11 }
    its([".member dd.age"]) {
      should all_be_gt_eq 10
      should all_be_lt 33
      should all_be_lt_eq 32
      should be_sorted :desc
    }
  end
end

describe "Status 200 check" do
  status_check [
      'http://localhost:4567/index.json',
      'http://localhost:4567/index'
  ]
end

