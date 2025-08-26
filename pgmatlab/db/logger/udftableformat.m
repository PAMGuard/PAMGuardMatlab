function [colNames, colTypes, createStmt] = udftableformat()
% get the names and types of udf table columns

% % con = sqlitedatabase('C:\PAMGuardTest\Goniometer\GoniometerTest.sqlite3')
% % tablesTable = con.fetch('select * from sqlite_master')
% % % tables(con)
% % %     dbmeta = dmd(con);
% % % %     t = tables(dbmeta,'');
% % %     colNames = columns(dbmeta, con.DefaultCatalog, '', 'UDF_Sample');
% % 
% % 
% % close(con);
createStmt = ['CREATE TABLE SAMPLETABLE ("Id" INTEGER NOT NULL, "Order" INTEGER, "Type" CHAR(50), ' ...
    '"Title" CHAR(50), "PostTitle" CHAR(50), "DbTitle" CHAR(50), "Length" INTEGER, "Topic" CHAR(50), ' ...
    '"NMEA_Module" CHAR(50), "NMEA_String" CHAR(50), "NMEA_Position" INTEGER, "Required" BOOLEAN, ' ...
    '"AutoUpdate" INTEGER, "Autoclear" BOOLEAN, "ForceGps" BOOLEAN, "Hint" CHAR(100), "ADC_Channel" INTEGER, ' ...
    '"ADC_Gain" REAL, "Analog_Multiply" REAL, "Analog_Add" REAL, "Plot" BOOLEAN, "Height" INTEGER, "Colour" CHAR(20), ' ...
    '"MinValue" REAL, "MaxValue" REAL, "ReadOnly" BOOLEAN, "Send_Control_Name" CHAR(50), "Control_on_Subform" CHAR(50), ' ...
    '"Get_Control_Data" CHAR(50), "Default" CHAR(50), PRIMARY KEY ("Id") )']
% pull a list of names and types out of that. 
quotes = strfind(createStmt, '"');
commas = strfind(createStmt, ',');
nCol = numel(quotes)/2-1;
for i = 1:nCol
    j = i-1;
    colNames{i} = createStmt(quotes(j*2+1)+1:quotes(j*2+2)-1);
    colTypes{i} = createStmt(quotes(j*2+2)+2:commas(i)-1);
end

