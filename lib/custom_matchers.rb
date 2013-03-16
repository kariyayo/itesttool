require 'rubygems'
require 'json-schema'

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
<<"MSG"

Invalid response body on "#{schema_file}".
#{@msg}

Body is
====================
#{body}

#{schema_file} is
====================
#{File.open(schema_file).read}

MSG
  end

  failure_message_for_should_not do |body|
    "\nValid response body on \"#{schema_file}\".\n\n"
  end
end


RSpec::Matchers.define :all_be_type_of do |type|
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

