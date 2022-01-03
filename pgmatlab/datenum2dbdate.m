function ds = datenum2dbdate(dn, delimChar)
if nargin < 2
    delimChar = '#';
end
% converts a datenum to the #mm/dd/yyyy hh:mm:ss# format required by SQL.
ds = [delimChar datestr(dn, 31) delimChar];