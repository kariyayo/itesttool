# coding: utf-8
require 'tiny_tds'
require 'yaml'

class Table
  @@config = YAML.load_file("config/database.yml")
  def initialize(dbname, tablename)
    @dbname = dbname
    @tablename = tablename
  end

  def where(condition)
    @condition = condition
    self
  end

  def find_all(&block)
    client = TinyTds::Client.new(
      :username => @@config[@dbname]['username'],
      :password => @@config[@dbname]['password'],
      :host => @@config[@dbname]['server'])
    condition = @condition.map {|k, v| client.escape(k.to_s) + "='" + client.escape(v.to_s) + "'" }.join(" AND ")
    sql = "SELECT * FROM #{@dbname}.dbo.#{@tablename} WHERE #{condition}"
#    pp sql
    result = client.execute(sql)
    block.call(result.entries) unless block.nil?
    result.entries
  end

  def find_one(&block)
    rows = find_all()
    case rows.size
      when 0 then
        raise "1件も取得できませんでした"
      when 1 then
        row = rows.first
        block.call(row) unless block.nil?
        row
      else
        raise "1件を超える件数が取得されました"
    end
  end
end

