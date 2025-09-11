function clearcolumn(con, table, col)
% function clearcolumn(con, table, col)
wh = sprintf('where %s is not null', col);
update(con, table, {col}, {'null'}, wh);