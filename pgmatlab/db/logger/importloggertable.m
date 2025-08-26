% import an old logger lookup table to a PAMGUArd sqlite database. 

xlsFile = 'C:\PAMGuardTest\Goniometer\xlsforms\Lookup.xlsx'
dbName = 'C:\PAMGuardTest\Goniometer\GoniometerTest.sqlite3'

con = sqlite(dbName);
[colNames, colTypes, createStmt] = lookuptableformat();

tableData = readtable(xlsFile)
h = size(tableData,1);
for i = 1:h
    tableData.Id(i) = i;
end

tableName = 'Lookup'

changes(1,:) = {'Order', 'DisplayOrder'};
changes(2,:) = {'Text', 'ItemText'};
changes(3,:) = {'Colour', 'FillColour'}
changes(4,:) = {'Selectable', 'isSelectable'};

xlsCols = tableData.Properties.VariableNames;
keep = ones(1,numel(xlsCols));
for i = 1:numel(xlsCols)
    f = find(strcmp(xlsCols{i}, changes(:,:)));
    if ~isempty(f)
        xlsCols{i} = changes{f,2};
    end
    % and check it's still a column we want
    f = find(strcmp(xlsCols{i},colNames));
    if isempty(f)
        keep(i) = 0;
        fprintf('Don''t keep xls column %s\n', xlsCols{i})
    end
end
tableData.Properties.VariableNames = xlsCols;
outData = tableData(:,find(keep))

con.exec('DELETE FROM Lookup');
con.sqlwrite(tableName, outData);

con.exec('UPDATE Lookup SET BorderColour = FillColour')

close(con);