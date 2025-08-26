function e = checkTable(con, tableName, create)
% Check a database table exists. 
% con database connection
% tableName database table name
% create flag to create the table with a single Id primary key in case it
% doesn't exist. 
if (nargin < 3)
    create = false;
end
e = 0;
if tableExists(con, tableName)
    e = 1;
    return;
end
if create 
    c = sprintf('CREATE TABLE %s (\"Id\" COUNTER NOT NULL, Primary Key (Id))', tableName);
    q = exec(con, c);
    e = tableExists(con, tableName);
end