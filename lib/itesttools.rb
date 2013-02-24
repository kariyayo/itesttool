require 'net/http'
require 'uri'

def _given(&block)
  before(:all, &block)
end

def _more(&block)
  before(:all, &block)
end

def _when(&block)
  before(:all, &block)
end

def _then(description = nil, &block)
  it(description, &block)
end

def _and(description = nil, &block)
  _then(description, &block)
end

def get(url)
  url = URI.parse(url)
  res = Net::HTTP.start(url.host, url.port) {|http|
      http.get(url.path)
  }
  res
end

RSpec::Matchers.define :be_status do |expectation|
  match do |res|
    res.code == expectation
  end
  failure_message_for_should do |res|
    "\nstatus code is not match.\nexpected: \"#{expectation}\"\n     got: \"#{res.code}\"\n\n"
  end
  failure_message_for_should_not do |res|
    "\nstatus code is match.\nexpected: \"#{expectation}\"\n     got: \"#{res.code}\"\n\n"
  end
end

