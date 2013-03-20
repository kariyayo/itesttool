$:.unshift File.dirname(__FILE__)
require 'custom_matchers'

require 'rubygems'
require 'net/http'
require 'uri'
require 'jsonpath'
require 'nokogiri'

def _given(&block)
  before(:all, &block)
end

def _when(obj, &block)
  context(obj, &block)
end

def get(url, h={})
  url_obj = URI.parse(url)
  res = Net::HTTP.start(url_obj.host, url_obj.port) {|http|
      http.get(url_obj.path)
  }
  class << res
    attr_accessor :url, :param
    def [](path)
      if param[:format] && param[:format].downcase == "xml"
        Nokogiri::XML(body).xpath(path).map{|x| x.text}
      else
        JsonPath.on(body, path)
      end
    end
    def to_s
      "GET " + url
    end
  end

  res.url = url
  res.param = h
  res
end

def status_check(code = "200", urls)
  urls.each do |url|
    context get url do
      its(:code) { should eq code.to_s }
    end
  end
end
