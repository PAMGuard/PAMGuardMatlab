function e = checkTable(con, tableName, create, colNames, colTypes)
% checkTable - Check a database table. 
%
%   Syntax:
%       e = checkTable(con, tableName, create, colNames, colTypes)
%       
% con       - database connection 
% tableName - database table name (char array)
% create    - flag to create the table with a single Id primary key in case it doesn't exist. 
% colNames  - a list of column names to add to the table
% colTypes  - a list of column types to add to the table
%
%   Examples:
%       e = checkTable(con, tableName)
%   Returns true if the table exists within the given database connection
%
%       e = checkTable(con, tableName, true)
%   Creates the table if it doesn't exist, and adds a single column Id set
%   to be a primary key. Returns true if the table then exists. 
%
%       e = checkTable(con, tableName, true, {'UTC', 'Duration', 'Comment'}, {'TIMESTAMP', 'DOUBLE', 'CHAR(50)'})
%   Creates the table if it doesn't exist, adds a single column Id set
%   to be a primary key and three other columns in the given format. Returns true if the table then exists. 
%   colNames and colTypes must be cell arrays of the same lengths. 

if nargin < 3
    create = false;
end

e = 0;
tableName = pgmatlab.utils.charArray(tableName);
if pgmatlab.db.tableExists(con, tableName)
    e = 1;
end
if e == 0 && create 
    c = sprintf('CREATE TABLE %s (\"Id\" COUNTER NOT NULL, Primary Key (Id))', tableName);
    exec(con, c);
    e = pgmatlab.db.tableExists(con, tableName);
end
if nargin >= 5
    colNames = pgmatlab.utils.charArray(colNames);
    colTypes = pgmatlab.utils.charArray(colTypes);
    nCol = numel(colNames);
    for i = 1:nCol
    c = pgmatlab.db.checkColumn(con, tableName, colNames{i}, colTypes{i});
    if c == 0
        e = 0;
    end
    end
end


