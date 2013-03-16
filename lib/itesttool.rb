require 'rubygems'
require 'net/http'
require 'uri'
require 'json-schema'
require 'jsonpath'

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
    def body_as_json
      JSON.parse body
    end
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

RSpec::Matchers.define :be_type_of do |type|
  match do |list|
    if type == Object
      false
    else
      @mismatch_indexes = list.each.with_index.find_all{|x, i| !(x.is_a? type)}.map{|x, i| i}
      [] == @mismatch_indexes
    end
  end
  failure_message_for_should do |list|
    if type == Object
      "Specified type is invalid. Valid type in [Integer, Float, String]"
    else
<<"MSG"
Type is mismatched. Expect type is #{type.to_s}. But got #{list.to_s}.
Mismatch index is #{@mismatch_indexes.to_s}.
MSG
    end
  end
  failure_message_for_should_not do |list|
    if type == Object
      "Specified type is invalid. Valid type in [Integer, Float, String]"
    else
<<"MSG"
Type is matched. Expect type is #{type.to_s}. Got #{list.to_s}.
Match index is #{@mismatch_indexes.to_s}.
MSG
    end
  end
end
