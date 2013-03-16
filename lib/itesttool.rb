$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'net/http'
require 'uri'
require 'jsonpath'
require 'custom_matchers'

def _given(&block)
  before(:all, &block)
end

def _when(obj, &block)
  context(obj, &block)
end

def get(url)
  url_obj = URI.parse(url)
  res = Net::HTTP.start(url_obj.host, url_obj.port) {|http|
      http.get(url_obj.path)
  }
  class << res
    attr_accessor :url
    def [](path)
      JsonPath.on(body, path)
    end
    def to_s
      "GET " + url
    end
  end

  res.url = url
  res
end

def status_check(code = "200", urls)
  urls.each do |url|
    context get url do
      its(:code) { should eq code.to_s }
    end
  end
end

