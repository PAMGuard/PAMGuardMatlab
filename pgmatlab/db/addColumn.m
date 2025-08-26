function e = addColumn(con, tableName, columnName, format);
cmd = sprintf('ALTER TABLE %s ADD COLUMN %s %s', tableName, columnName, format);
exec(con, cmd);
e = columnExists(con, tableName, columnName);