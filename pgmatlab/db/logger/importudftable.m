% convert a set of udf table from access to sqlite. 
% tables were first exported as excel files. 
sqDb = 'C:\PAMGuardTest\Goniometer\GoniometerTest.sqlite3'

con = sqlite(sqDb);
[colNames, colTypes, createStmt] = udftableformat();

changes(1,:) = {'NMEAString', 'NMEA_String'};
changes(2,:) = {'NMEAPosition', 'NMEA_Position'};
changes(3,:) = {'ADCChannel', 'ADC_Channel'};
changes(4,:) = {'ADCGain', 'ADC_Gain'};
changes(5,:) = {'AnalogMultiply', 'Analog_Multiply'};
changes(6,:) = {'AnalogAdd', 'Analog_Add'};
changes(7,:) = {'AutoClear', 'Autoclear'};
changes(8,:) = {'SendControlName', 'Send_Control_Name'};
changes(9,:) = {'ControlOnSubform', 'Control_on_Subform'};
changes(10,:) = {'GetControlData', 'Get_Control_Data'};
changes(11,:) = {'Order', 'dumOrder'};
changes(12,:) = {'Default', 'dumDefault'};

root = 'C:\PAMGuardTest\Goniometer\xlsforms\';
forms = dir([root '*.xlsx'])

for i = 1:numel(forms)
    xlsFile = fullfile(forms(i).folder, forms(i).name)
    xlsData = readtable(xlsFile)
    nRow = height(xlsData);
    for ir = 1:nRow
        xlsData.Id(ir) = ir;
    end
    xlsCols = xlsData.Properties.VariableNames;
    for x = 1:size(changes,1) 
        f = find(strcmp(xlsCols,changes{x,1}));
        xlsCols{f} = changes{x,2};
    end
    xlsData.Properties.VariableNames = xlsCols;

    for x = 1:numel(xlsCols)
        f = find(strcmp(colNames, xlsCols{x}));
        if numel(f) ~= 1
            fprintf('unable to find excel column ''%s'' in table\n', xlsCols{x})
        end
    end

    [~, tableName] = fileparts(xlsFile)
    tableName = strrep(tableName,' ', '');
    tableName = ['"' tableName '"'];
    createLine = strrep(createStmt, 'SAMPLETABLE', ['' tableName '']);
    try
    con.exec(['DROP Table ' tableName ''])
    catch
    end
    con.exec(createLine)
    con.exec(sprintf('ALTER TABLE %s ADD COLUMN "dumOrder" INTEGER', tableName));
    con.exec(sprintf('ALTER TABLE %s ADD COLUMN "dumDefault" CHAR(50)', tableName));
    % now need to dealwith null data, which the connectin is crap at
    for ir = 1:nRow
        aRow = xlsData(ir,:);
        isnull = columnisnull(aRow);
        % get a single row out of the table
        rowTable = xlsData(ir,find(~isnull));
        rowTable = fixBooleans(rowTable);
        % rowTable = rowTable(1,[2:end]);
        con.sqlwrite(tableName, rowTable);
    end
    stmt = sprintf('UPDATE %s SET "Order" = "dumOrder"', tableName);
    con.exec(stmt);
    con.exec(sprintf('ALTER TABLE %s DROP COLUMN "dumOrder"', tableName));
    stmt = sprintf('UPDATE %s SET "Default" = "dumDefault"', tableName);
    con.exec(stmt);
    con.exec(sprintf('ALTER TABLE %s DROP COLUMN "dumDefault"', tableName));

    % break
end

close(con)

function row = fixBooleans(row)
w = size(row,2);
for i = 1:w
    bit = row{1,i};
    if (islogical(i))
    end
end
end

function isnull = columnisnull(data)
w = size(data,2);
isnull = zeros(1,w);
names = data.Properties.VariableNames 
for i = 1:w
    bit = data{1,i};
    if iscell(bit)
        bit = bit{1};
    end
    if isnumeric(bit)
        if isnan(bit)
            isnull(i) = 1;
        end
    end
    if ischar(bit)
        if length(bit) == 0
            isnull(i) = 1;
        end
    end
    if isstring(bit)
        if length(bit) == 0
            isnull(i) = 1;
        end
    end
end
end