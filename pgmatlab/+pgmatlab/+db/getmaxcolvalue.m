function m = getmaxcolvalue(con, tableName, colName)
% get maximum integer value of a column. Return [] if the table is empty
m = [];
try % sqlite database throws up if no data. 
    qStr = sprintf('SELECT MAX(%s) FROM %s', colName, tableName);
    dat = con.fetch(qStr);
    if height(dat) == 1
        m = table2array(dat(1,1));
    end
    if isnan(m)
        m = [];
    end
catch
end
