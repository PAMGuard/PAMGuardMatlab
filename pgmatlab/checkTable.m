function e = checkTable(con, tableName, create)
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