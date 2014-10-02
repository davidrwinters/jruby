require 'java'

module JavaLang
	include_package "java.lang"
end

module JavaSql
	include_package 'java.sql'
end

import 'org.apache.derby.jdbc.ClientDriver'

def createIfNotExists(conn, query, ddl)
  stmt = conn.createStatement
  rs = stmt.executeQuery(query)
  schemaCount = 0
  if (rs.next) then
    count = rs.getInt("c");
    puts "count=[" + count.to_s + "] --> " + query
    if (count == 0) then
      puts "Creating DDL: " + ddl
      stmt2 = conn.createStatement
      stmt2.executeUpdate(ddl)
      conn.commit
      stmt2.close
    end
  end
  rs.close
  stmt.close
end

def readFromTable(conn, count, total)
  puts "Read from table: count=" + count.to_s + ", total=" + total.to_s
  stmt = conn.createStatement
  rs = stmt.executeQuery("select id, name from fred.test_ruby order by id")
  counter = 0
  while (rs.next) do
    counter+=1
    puts "Record=[" + counter.to_s + "] id=[" + rs.getInt("id").to_s + "] name=[" + rs.getString("name") + "]"
  end
  rs.close
  stmt.close
end

def writeIntoTable(conn, count, total)
  puts "Write into table: count=" + count.to_s + ", total=" + total.to_s
  stmt = conn.createStatement
	stmt.executeUpdate("insert into fred.test_ruby(id, name) values (default, 'hello')")
  conn.commit();
end

begin
	conn = JavaSql::DriverManager.getConnection("jdbc:derby://localhost:1527/splicedb", "splice", "admin");

  ### Check for the schema and create it if necessary. ###
	createIfNotExists(conn, "select count(*) as c from sys.sysschemas where schemaname = 'FRED'", "create schema fred")

  ### Check for the table and create it if necessary. ###
  createIfNotExists(conn, "select count(*) as c from sys.sysschemas s, sys.systables t where s.schemaid = t.schemaid and s.schemaname = 'FRED' and t.tablename = 'TEST_RUBY'", "create table fred.test_ruby (id int NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1), name varchar(100))")

  readCounter = 0
  writeCounter = 0

  while (true) do
    puts "====================================================================="
    puts "Total Reads = " + readCounter.to_s + ", Total Writes = " + writeCounter.to_s
    puts "====================================================================="
    n = rand(0..1)
    if (n == 0) then
      readCounter += 1
      ### Dump the contents of the table to stdout ###
      readFromTable(conn, 1, 1)
    else
      writeCounter += 1
      ### Insert a bunch of records ###
      writeIntoTable(conn, 1, 1)
    end
	end

	conn.close()
rescue JavaLang::ClassNotFoundException => e
	$stderr.print "Java told me: #{e}n"
rescue JavaSql::SQLException => e
	$stderr.print "Java told me: #{e}n"
end
