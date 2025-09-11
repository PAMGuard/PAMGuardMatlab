function e = columnExists(con, tableName, columnName)
% function e = columnExists(con, tableName, columnName)
% check to see if a column exists in a database table
%
% con: database connection
% tableName: database table name
% columnName: database column name
%
% returns 1 (true) if the column exists, 0 (false) otherwise. 
e = 0;
%% This method worked and may still work for ODBC database connections.
try  
    dbmeta = dmd(con);
%     t = tables(dbmeta,'');
    colNames = columns(dbmeta, con.DefaultCatalog, '', tableName);
    e = sum(strcmp(lower(columnName), lower(colNames)));
    return
catch
end
%% This method works for connections established with the sqlitedatabase function
%% and for connections using the Matlab sqlite connection function
try
    sq = sprintf('SELECT sql FROM sqlite_master where name=''%s''', tableName);
    tableData = con.fetch(sq);
    if size(tableData,1) == 0
        return;
    end
    search = ['"' columnName '"'];
    has = strfind(tableData.sql, search);
    if isempty(has)
        e = 0;
        return;
    end
    if iscell(has)
        has = has{1};
        if isempty(has)
            e = 0;
            return;
        end
    end
    dat = has(1);
    e = ~isempty(dat);
    return
catch er
end
er
error('Unable to perform column checks for this type of database');