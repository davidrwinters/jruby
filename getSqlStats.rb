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
    getIndexInfoQuery = "call sysibm.sqlstatistics(null, null, null, 1, 0, null)"

    ### Dump the index info to stdout ###
    pstmt = conn.prepareStatement(getIndexInfoQuery)

    for i in 1 .. 10
        rs = pstmt.executeQuery()
        counter = 0
        while (rs.next) do
            counter+=1
            puts "Run=[" + i.to_s +
                "], Record=[" + counter.to_s +
                "], table_schem=[" + rs.getString("table_schem").to_s +
                "], table_name=[" + rs.getString("table_name") +
                "], index_name=[" + rs.getString("index_name") +
                "], ordinal_position=[" + rs.getString("ordinal_position") +
                "], column_name=[" + rs.getString("column_name") +
                "]"
        end
        rs.close
    end

    pstmt.close
    conn.close()
rescue JavaLang::ClassNotFoundException => e
    $stderr.print "Java told me: #{e}n"
rescue JavaSql::SQLException => e
    $stderr.print "Java told me: #{e}n"
end
