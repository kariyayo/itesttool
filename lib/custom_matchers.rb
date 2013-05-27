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

Invalid response body on "#{@schema_file}".
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


def be_sorted(order)
  BeSorted.new(order)
end

class BeSorted
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
      "expected #{@list.inspect} type is not available."
    elsif @order_invalid
      "specified order is invalid. valid order in [:asc, :desc]"
    else
      "expected #{@list.inspect} to be sorted #{@order}"
    end
  end
end


def all(meta)
  All.new(meta)
end

class All
  def initialize(matcher)
    @matcher = matcher
  end

  def matches?(rows)
    rows.each_with_index do |i, j|
      @elem = j
      unless @matcher.matches? i
        return false
      end
    end
    return true
  end

  def failure_message_for_should
    "at[#{@elem}] #{@matcher.failure_message_for_should}"
  end

end


def be_one_and(meta)
  BeOneAnd.new(meta)
end

class BeOneAnd
  def initialize(matcher)
    @matcher = matcher
  end

  def matches?(rows)
    @have_error = false
    @have = RSpec::Matchers::BuiltIn::Have.new(1).items
    unless @have.matches? rows then
      @have_error = true
      return false;
    end
    @matcher.matches? rows[0]
  end

  def failure_message_for_should
    if @have_error 
      @have.failure_message_for_should
    else
      @matcher.failure_message_for_should
    end
  end

end

