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

def as_json
  "json"
end
def as_xml
  "xml"
end
def as_html
  "html"
end
def get(url, res_format = "json", h={})
  url_obj = URI.parse(url)
  res = Net::HTTP.start(url_obj.host, url_obj.port) {|http|
    request = Net::HTTP::Get.new(url_obj.path)
    h.each{|k, v| request.add_field k, v}
    http.request(request)
  }
  class << res
    attr_accessor :url, :res_format
    def [](path)
      if res_format && res_format == "xml"
        Nokogiri::XML(body).xpath(path).map{|x| x.text}
      elsif res_format  && res_format == "html"
        Nokogiri::HTML(body).css(path).map{|x| x.text}
      else
        JsonPath.on(body, path)
      end
    end
    def to_s
      "GET " + url
    end
  end

  res.url = url
  res.res_format = res_format
  res
end

def status_check(code = "200", urls)
  urls.each do |url|
    context get url do
      its(:code) { should eq code.to_s }
    end
  end
end
