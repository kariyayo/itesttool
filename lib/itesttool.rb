def _given(&b) before(:each, &b) end
def _when(&b) let(:res, &b) end
def _then(&b) it(&b) end

def status_check(code = "200", urls)
  include ItestHelpers
  urls.each do |url|
    context ItestHelpers.get url do
      its(:code) { should eq code.to_s }
    end
  end
end


module ItestHelpers
  $:.unshift File.dirname(__FILE__)
  require 'custom_matchers'
  require 'rubygems'
  require 'net/http'
  require 'uri'
  require 'jsonpath'
  require 'nokogiri'

  def as_json() "json" end
  def as_xml() "xml" end
  def as_html() "html" end

  alias res_as_json as_json
  alias res_as_xml as_xml
  alias res_as_html as_html

  def headers(h = {})
    @h = h
  end

  def get(url, res_format = "json", h={})
    url_obj = URI.parse(url)
    res = Net::HTTP.start(url_obj.host, url_obj.port) {|http|
      request = Net::HTTP::Get.new(url_obj.path)
      add_headers(request, h)
      http.request(request)
    }
    decorate_response(res, "GET", url, res_format)
  end

  def post(url, data, res_format = "json", h={})
    url_obj = URI.parse(url)
    res = Net::HTTP.start(url_obj.host, url_obj.port) {|http|
      request = Net::HTTP::Post.new(url_obj.path)
      request.set_form_data(data, "&")
      add_headers(request, h)
      http.request(request)
    }
    decorate_response(res, "POST", url, res_format)
  end

private
  def add_headers(request, h={})
    if @h then h.merge! @h end
    h.each{|k, v| request.add_field k, v}
  end

  def decorate_response(res, method, url, res_format)
    class << res
      attr_accessor :url, :res_format, :method
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
        method + " " + url
      end
    end
    res.url = url
    res.res_format = res_format
    res.method = method
    res
  end

  module_function :get, :post, :add_headers, :decorate_response
end


RSpec.configure do |c|
    c.include ItestHelpers
end

