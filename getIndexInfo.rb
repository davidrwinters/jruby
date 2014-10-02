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
    getIndexInfoQuery = <<DOC
  SELECT CAST('' AS VARCHAR(128)) AS TABLE_CAT, \
       S.SCHEMANAME AS TABLE_SCHEM, \
       T.TABLENAME AS TABLE_NAME, \
       'N/A' AS NON_UNIQUE, \
       CAST ('' AS VARCHAR(128)) AS INDEX_QUALIFIER, \
       CONGLOMS.CONGLOMERATENAME AS INDEX_NAME, \
       'N/A' AS TYPE, \
       'N/A' AS ORDINAL_POSITION, \
       COLS.COLUMNNAME AS COLUMN_NAME, \
       'N/A' AS ASC_OR_DESC, \
       CAST(NULL AS INT) AS CARDINALITY, \
       CAST(NULL AS INT) AS PAGES, \
       CAST(NULL AS VARCHAR(128)) AS FILTER_CONDITION, \
       CONGLOMS.CONGLOMERATENUMBER AS CONGLOM_NO \
  FROM SYS.SYSSCHEMAS S, \
      SYS.SYSTABLES T, \
      SYS.SYSCONGLOMERATES CONGLOMS, \
      SYS.SYSCOLUMNS COLS \
  WHERE T.TABLEID = CONGLOMS.TABLEID AND T.TABLEID = COLS.REFERENCEID \
    AND T.SCHEMAID = S.SCHEMAID \
    AND CONGLOMS.ISINDEX \
    AND true \
    AND S.SCHEMANAME LIKE ? AND T.TABLENAME LIKE ? \
    AND true \
  ORDER BY TABLE_SCHEM, TABLE_NAME, INDEX_NAME, ORDINAL_POSITION
DOC

    ### Dump the index info to stdout ###
    pstmt = conn.prepareStatement(getIndexInfoQuery)
    pstmt.setString(1, "%");
    pstmt.setString(2, "%");
    rs = pstmt.executeQuery()
    counter = 0
    while (rs.next) do
        counter+=1
        puts "Record=[" + counter.to_s +
            "], table_schem=[" + rs.getString("table_schem").to_s +
            "], table_name=[" + rs.getString("table_name") +
            "], index_name=[" + rs.getString("index_name") +
            "], ordinal_position=[" + rs.getString("ordinal_position") +
            "], column_name=[" + rs.getString("column_name") +
            "]"
    end
    rs.close
    pstmt.close
    conn.close()
rescue JavaLang::ClassNotFoundException => e
    $stderr.print "Java told me: #{e}n"
rescue JavaSql::SQLException => e
    $stderr.print "Java told me: #{e}n"
end
