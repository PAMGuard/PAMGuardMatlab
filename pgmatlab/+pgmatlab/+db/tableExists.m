function e = tableExists(con, tableName)
% function e = tableExists(con, tableName)
% return true if the table exists in connection con
e = 0;
%% ODBC Method
try
    dbmeta = dmd(con, 'tables');
    t = tables(dbmeta,'');
    n = size(t,1);
    for i = 1:n
        tt = t{i,1};
        if strcmp(lower(tt),lower(tableName)) == 1
            e = 1;
            return;
        end
    end
    return
catch
end
%% SQLITE Method
try
    sq = sprintf('SELECT * FROM sqlite_master where name=''%s''', tableName);
    tableData = con.fetch(sq);
    e = size(tableData,1) > 0;
    return
catch
end