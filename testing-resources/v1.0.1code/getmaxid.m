function mid = getMaxId(con, tableName, idName)
% get the current max id for a database table.
if nargin < 3
    idName = 'Id';
end
mid = 0;
mQuery = sprintf('SELECT max(%s) as MaxId FROM %s', idName, tableName);
try
    data = con.fetch(mQuery);
    if height(data) > 0
        mid = data.MaxId(1);
        if isnan(mid)
            mid = 0;
        end
    end
catch
    mid = 0;
end
end