% check some functionality works with both the Matlab built in sqlite
% function and also with my own sqlitedatabase function

dbName = 'C:\ProjectData\RobRiver\Y4_2023_2024_offline\RobRiver_Yr4_annotationsReproc240303.sqlite3'
tableName = 'Auto_Seal'
colName = 'UID'
con = sqlite(dbName)
pgmatlab.db.tableExists(con, tableName)

% pStr = sprintf('PRAGMA table_Info(''%s'')', tableName);
% con.fetch(pStr)

sq = sprintf('SELECT * FROM sqlite_master where name=''%s''', tableName);
con.fetch(sq)

pgmatlab.db.columnExists(con, tableName, colName)

close(con)

