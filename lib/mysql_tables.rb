require 'mysql'


class Table
  @@config = YAML.load_file("config/database.yml")
  def initialize(db_name, name)
    @db_name = db_name
    @name = name
  end

  def where(condition)
    @condition = condition
    self
  end

  def query
    ENV["MYSQL_UNIX_PORT"] = @@config[@db_name]['socket']
    client =
      Mysql.connect(
        @@config[@db_name]['server'],
        @@config[@db_name]['username'],
        @@config[@db_name]['password'],
        @db_name)
    sql = "SELECT * FROM #{client.escape_string(@name)} " +
      if @condition.nil? then "" else mkwhere(client, @condition) end
    rows = client.query(sql)
    fnames = rows.fields.map {|f| f.name}
    rows.to_a.map {|values|
      arr = [fnames, values].transpose
      Hash[*arr.flatten]
    }
  end

private
  def mkwhere(dbclient, condition)
    cond = condition.map {|k, v|
      dbclient.escape_string(k.to_s) + "='" + dbclient.escape_string(v.to_s) +"'"
    }.join(" AND ")
    if cond.empty?
      ""
    else
      "WHERE " + cond
    end
  end
end

