require 'java'

module JavaLang
    include_package "java.lang"
end

module JavaSql
    include_package 'java.sql'
end

import 'org.apache.derby.jdbc.ClientDriver'

begin
    conn = JavaSql::DriverManager.getConnection("jdbc:derby://localhost:1527/splicedb");

    ### Dump the contents of the table to stdout ###
    puts "Table Before:"
    stmt = conn.createStatement
    rs = stmt.executeQuery("select id, name from test_ruby")
    counter = 0
    while (rs.next) do
        counter+=1
        puts "Record=[" + counter.to_s + "] id=[" + rs.getInt("id").to_s + "] name=[" + rs.getString("name") + "]"
    end
    rs.close
    stmt.close

    ### Get the max ID ###
    stmt = conn.createStatement
    rs = stmt.executeQuery("select max(id) as maxid from test_ruby")
    maxID = 0
    if (rs.next) then
        maxID = rs.getInt("maxid");
        puts "maxID=[" + maxID.to_s + "]"
    end
    rs.close
    stmt.close

    ### Insert a bunch of records ###
    puts "Insert new records"
    pstmt = conn.prepareStatement("insert into test_ruby(id, name) values (?, ?)")
    for i in 1 .. 10
        pstmt.setInt(1, maxID+i);
        pstmt.setString(2, "hello");
        pstmt.executeUpdate();
    end
    conn.commit();

    ### Dump the contents of the table to stdout ###
    puts "Table After:"
    stmt = conn.createStatement
    rs = stmt.executeQuery("select id, name from test_ruby order by id")
    counter = 0
    while (rs.next) do
        counter+=1
        puts "Record=[" + counter.to_s + "] id=[" + rs.getInt("id").to_s + "] name=[" + rs.getString("name") + "]"
    end
    rs.close
    stmt.close

    conn.close()
rescue JavaLang::ClassNotFoundException => e
    $stderr.print "Java told me: #{e}n"
rescue JavaSql::SQLException => e
    $stderr.print "Java told me: #{e}n"
end
