function [colNames, colTypes, createStmt] = lookuptableformat()
% get the format of a standard PAMGuard lookup table. 

% these lines were run once on an existing database to get the 
% table formats, a result was then copied manually as createStmt
% con = sqlite('C:\PAMGuardTest\Goniometer\GoniometerTest.sqlite3')
% tablesTable = con.fetch('select * from sqlite_master')
% close(con)

createStmt = ['CREATE TABLE Lookup ("Id" INTEGER NOT NULL, "Topic" CHAR(50), ' ...
    '"DisplayOrder" INTEGER, "Code" CHAR(12), "ItemText" CHAR(50), "isSelectable" BIT, ' ...
    '"FillColour" CHAR(20), "BorderColour" CHAR(20), "Symbol" CHAR(2), PRIMARY KEY ("Id") )'];

quotes = strfind(createStmt, '"');
commas = strfind(createStmt, ',');
nCol = numel(quotes)/2-1;
for i = 1:nCol
    j = i-1;
    colNames{i} = createStmt(quotes(j*2+1)+1:quotes(j*2+2)-1);
    colTypes{i} = createStmt(quotes(j*2+2)+2:commas(i)-1);
end