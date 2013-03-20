require 'rubygems'
require 'json-schema'

def eq_schema_of(schema_file)
  EqSchemaOf.new(schema_file)
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


def all_be_type_of(type)
  AllBeTypeOf.new(type)
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


module CollectionMatchUtil
  def element_matches?(list, type, &p)
    @list = list
    list_type = list.first.class
    unless list.all?{|x| x.class == list_type }
      @not_aligned = true
      false
    else
      begin
        @mismatch_indexes = list.each.with_index.find_all{|x, i|
          !(p.call(convert x, type))
        }.map{|x, i| i}
        @mismatch_indexes.size == 0
      rescue ArgumentError => e
        @not_aligned = true
        false
      end
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
private
  def convert (x, type)
    if type == Integer || type == Fixnum
      Integer(x)
    elsif type == Float
      x.to_f
    elsif type == String
      x.to_s
    else
      x
    end
  end
end


def all_be_gt(min)
  AllBeGt.new(min)
end

class AllBeGt
  include CollectionMatchUtil
  def initialize(min)
    @min = min
  end
  def matches?(list)
    element_matches?(list, @min.class){|x| x > @min }
  end
  def msg_of_base_for_should
    "expected #{@list} to all be gt #{@min}"
  end
  def msg_of_base_for_should_not
    "expected #{@list} not to all be gt #{@min}"
  end
end


def all_be_gt_eq(min)
  AllBeGtEq.new(min)
end

class AllBeGtEq
  include CollectionMatchUtil
  def initialize(min)
    @min = min
  end
  def matches?(list)
    element_matches?(list, @min.class){|x| x >= @min }
  end
  def msg_of_base_for_should
    "expected #{@list} to all be gt eq #{@min}"
  end
  def msg_of_base_for_should_not
    "expected #{@list} not to all be gt eq #{@min}"
  end
end


def all_be_lt(max)
  AllBeLt.new(max)
end

class AllBeLt
  include CollectionMatchUtil
  def initialize(max)
    @max = max
  end
  def matches?(list)
    element_matches?(list, @max.class){|x| x < @max }
  end
  def msg_of_base_for_should
    "expected #{@list} to all be lt #{@min}"
  end
  def msg_of_base_for_should_not
    "expected #{@list} not to all be lt #{@min}"
  end
end


def all_be_lt_eq(max)
  AllBeLtEq.new(max)
end

class AllBeLtEq
  include CollectionMatchUtil
  def initialize(max)
    @max = max
  end
  def matches?(list)
    element_matches?(list, @max.class){|x| x <= @max }
  end
  def msg_of_base_for_should
    "expected #{@list} to all be lt eq #{@min}"
  end
  def msg_of_base_for_should_not
    "expected #{@list} not to all be lt eq #{@min}"
  end
end


def be_sorted(order)
  BeSorted.new(order)
end

class BeSorted
  include CollectionMatchUtil
  def initialize(order)
    @order = order
  end
  def matches?(list)
    @list = list
    type = list.first.class
    unless list.all?{|x| x.class == type }
      @not_aligned = true
      false
    else
      sorted_list = list.sort
      if @order == :asc
        list == sorted_list
      elsif @order == :desc
        list == sorted_list.reverse
      else
        @order_invalid = true
        false
      end
    end
  end

  def failure_message_for_should
    if @not_aligned
      msg_of_type_not_aligned
    elsif @order_invalid
      msg_of_type_invalid
    else
      "expected #{@list} to be sorted #{@order}"
    end
  end

private
  def msg_of_type_invalid
    "specified order is invalid. valid order in [:asc, :desc]"
  end
end

