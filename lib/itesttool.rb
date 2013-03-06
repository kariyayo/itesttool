require 'rubygems'
require 'net/http'
require 'uri'
require 'json-schema'

def _given(&block)
  before(:all, &block)
end

def _when(obj, &block)
  context(obj, &block)
end

def get(url)
  url = URI.parse(url)
  res = Net::HTTP.start(url.host, url.port) {|http|
      http.get(url.path)
  }
  class << res
    def body_as_json
      JSON.parse body
    end
  end
  res
end

def status_check(code = "200", urls)
  urls.each do |url|
    it "code should eq " + code.to_s do
      (get url).code.should eq code.to_s
    end
  end
end

RSpec::Matchers.define :be_status do |expectation|
  match do |res|
    res.code == expectation
  end
  failure_message_for_should do |res|
    "\nStatus code is not match.\nexpected: \"#{expectation}\"\n     got: \"#{res.code}\"\n\n"
  end
  failure_message_for_should_not do |res|
    "\nStatus code is match.\nexpected: \"#{expectation}\"\n     got: \"#{res.code}\"\n\n"
  end
end

RSpec::Matchers.define :eq_schema_of do |schema_file|
  match do |body|
    @msg = ""
    begin
      JSON::Validator.validate!(schema_file, body)
      true
    rescue JSON::Schema::ValidationError
      @msg = $!.message
      false
    end
  end
  failure_message_for_should do |body|
    "\nInvalid response body on \"#{schema_file}\".\n" +
      @msg +"\n\n" +
      "Body is\n====================\n" + body + "\n\n" +
      "#{schema_file} is\n====================\n" + File.open(schema_file).read + "\n\n"
  end
  failure_message_for_should_not do |body|
    "\nValid response body on \"#{schema_file}\".\n\n"
  end
end

