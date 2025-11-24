function e = addColumn(con, tableName, columnName, format);
%addColumn - adda column to a database table
%
%   Syntax:
%       e = addColumn(con, tableName, columnName, format);
cmd = sprintf('ALTER TABLE %s ADD COLUMN %s %s', tableName, columnName, format);
exec(con, cmd);
e = pgmatlab.db.columnExists(con, tableName, columnName);