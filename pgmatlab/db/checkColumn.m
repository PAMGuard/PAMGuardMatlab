function e = checkColumn(con, tableName, columnName, format);
% function e = checkColumn(con, tableName, columnName, format)
% checks a database table column, adding it if it doesn't exist. 
e = columnExists(con,tableName, columnName);
if e
    return
end
cmd = sprintf('ALTER TABLE %s ADD COLUMN %s %s', tableName, columnName, format);
ans = exec(con, cmd);
e = columnExists(con, tableName, columnName);