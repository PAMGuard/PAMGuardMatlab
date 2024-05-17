function ds = datenum2dbdate(dn, delimChar, millis)
if nargin < 2
    delimChar = '#';
end
if nargin < 3
    millis = false;
end
% converts a datenum to the #mm/dd/yyyy hh:mm:ss# format required by SQL.
if millis
ds = [delimChar datestr(dn, 'yyyy-mm-dd HH:MM:SS.FFF') delimChar];
else
ds = [delimChar datestr(dn, 31) delimChar];
end