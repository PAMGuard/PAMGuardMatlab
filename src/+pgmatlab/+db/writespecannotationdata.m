function n = writespectrogramannotationdata(dbName, tableName, data, exColNames, exColTypes)
% finally getting around to making a nice function to write data into a
% PAMGuard spectrogram annotations table. Well, not nice, but at least
% reusable.
colNames = {'Id', 'UID', 'UTC', 'UTCMilliseconds', 'PCLocalTime', 'PCTime', 'ChannelBitmap',...
    'SequenceBitmap', 'Duration', 'f1', 'f2'}
colTypes = {'INTEGER NOT NULL', 'INTEGER', 'TIMESTAMP', 'INTEGER', 'TIMESTAMP', 'TIMESTAMP', 'INTEGER',...
    'INTEGER', 'DOUBLE', 'DOUBLE', 'DOUBLE'};
if nargin >= 5
    colNames = [colNames, exColNames];
    colTypes = [colTypes, exColTypes];
end
con = sqlite(dbName);
checkTable(con, tableName, true);
for i = 1:numel(colNames)
    checkColumn(con, tableName, colNames{i}, colTypes{i});
end

maxId = getmaxcolvalue(con, tableName, 'Id');
maxUID = getmaxcolvalue(con, tableName, 'UID');
if isempty(maxId)
    maxId = 0;
end
if isempty(maxUID)
    maxUID = 0;
end

close(con)

% now put data into a table and insert. Data must either be a structure
% or a table in the correct format.
if istable(data)
    tableData = data;
elseif isstruct(data)
    cData = cell(numel(data), numel(colNames));
    for i = 1:numel(data)
        maxId = maxId + 1;
        maxUID = maxUID + 1;
        cData{i,1} = maxId;
        cData{i,2} = maxUID;
        cData{i,3} = data(i).UTC;
        if isnumeric(cData{i,3});
            cData{i,3} = datenum2dbdate(cData{i,3}, '', true);
        end
        cData{i,4} = 0;
        cData{i,5} = cData{i,3};
        cData{i,6} = datenum2dbdate(now(), '', true);
        cData{i,7} = data(i).ChannelBitmap;
        cData{i,8} = cData{i,7};
        cData{i,9} = data(i).Duration;
        cData{i,10} = data(i).f1;
        cData{i,11} = data(i).f2;
        if nargin >= 5
            for j = 1:numel(exColNames)
                cData{i,11+j} = getfield(data(i), exColNames{j});
            end
        end
    end
    tableData = cell2table(cData, 'VariableNames',colNames);
end
con = sqlite(dbName);
con.sqlwrite(tableName, tableData);
close(con);
end
