require 'rubygems'
require 'json-schema'

module CollectionMatchUtil
  def element_matches?(list, &p)
    @list = list
    @not_aligned = false
    type = list.first.class
    unless list.all?{|x| x.class == type }
      @not_aligned = true
      false
    else
      @mismatch_indexes = list.each.with_index.find_all{|x, i| !(p.call(x)) }.map{|x, i| i}
      @mismatch_indexes.size == 0
    end
  end

  def failure_message_for_should
    if @not_aligned
      msg_of_type_not_aligned
    else
<<"MSG"
#{msg_of_base_for_should}
#{msg_of_mismatch_indexes}
MSG
    end
  end

  def failure_message_for_should_not
    @not_aligned ? msg_of_type_not_aligned : msg_of_base_for_should
  end

  def msg_of_mismatch_indexes
    "mismatch indexes is #{@mismatch_indexes}"
  end

  def msg_of_type_not_aligned
    "expected #{@list} type is not available."
  end
end


def eq_schema_of(schema_file)
  EqSchemaOf.new(schema_file)
end

def all_be_type_of(type)
  AllBeTypeOf.new(type)
end

def all_be_gt(min)
  AllBeGt.new(min)
end

def all_be_gt_eq(min)
  AllBeGtEq.new(min)
end


class EqSchemaOf
  def initialize(schema_file)
    @schema_file = schema_file
  end
  def matches? (body)
    @body = body
    @msg = ""
    begin
      JSON::Validator.validate!(@schema_file, body)
      true
    rescue JSON::Schema::ValidationError
      @msg = $!.message
      false
    end
  end

  def failure_message_for_should
<<"MSG"

Invalid response body on "#{schema_file}".
#{@msg}

Body is
====================
#{@body}

#{@schema_file} is
====================
#{File.open(@schema_file).read}

MSG
  end

  def failure_message_for_should_not
    "\nValid response body on \"#{@schema_file}\".\n\n"
  end
end



class AllBeTypeOf
  def initialize(type)
    @type = type
  end

  def matches? (list)
    @list = list
    @type_invalid = false
    t =
      case @type
      when :integer
        Integer
      when :string
        String
      when :float
        Float
      else
        @type_invalid = true
        Object
      end
    if @type_invalid
      false
    else
      @mismatch_indexes = list.each.with_index.find_all{|x, i| !(x.is_a? t)}.map{|x, i| i}
      [] == @mismatch_indexes
    end
  end

  def failure_message_for_should
    if @type_invalid
      msg_of_type_invalid
    else
<<"MSG"
expected #{@list} to all be type of #{@type}
mismatch index is #{@mismatch_indexes}
MSG
    end
  end

  def failure_message_for_should_not
    @type_invalid ? msg_of_type_invalid : "expected #{@list} not to all be type of #{@type}"
  end

private
  def msg_of_type_invalid
    "specified type is invalid. valid type in [:integer, :float, :string]"
  end
end


class AllBeGt
  include CollectionMatchUtil
  def initialize(min)
    @min = min
  end
  def matches?(list)
    element_matches?(list){|x| x > @min }
  end
  def msg_of_base_for_should
    "expected #{@list} to all be gt #{@min}"
  end
  def msg_of_base_for_should_not
    "expected #{@list} not to all be gt #{@min}"
  end
end


class AllBeGtEq
  include CollectionMatchUtil
  def initialize(min)
    @min = min
  end
  def matches?(list)
    element_matches?(list){|x| x >= @min }
  end
  def msg_of_base_for_should
    "expected #{@list} to all be gt eq #{@min}"
  end
  def msg_of_base_for_should_not
    "expected #{@list} not to all be gt eq #{@min}"
  end
end


