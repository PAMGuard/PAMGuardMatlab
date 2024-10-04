function [dn, millis] = dbdate2datenum(dbdate)
dbdate=convertStringsToChars(dbdate);

% function dn = dbdate2datenum(dbdate)
%  converts a YYYY-MM-DD HH:MM:SS.ms datestring returned from a database
%  into a datenum (standard Matlab time)
if iscell(dbdate)
    n = length(dbdate);
    dn = zeros(size(dbdate));
    millis = zeros(size(dbdate));
    for i = 1:n
        [aDate, ms] = dbdate2datenum(dbdate{i});
        dn(i) = aDate;
        millis(i) = ms;
    end
    return;
end
if size(dbdate,1) > 1
    % this will happen if it's an array of UTC times read from a table.
    n = size(dbdate, 1);
if isstring(dbdate)
    dbdate = char(dbdate);
    dn = zeros(n,1);
    millis = zeros(n,1);
    for i = 1:n
        try
        [aDate, ms] = dbdate2datenum(dbdate(i,:));
        dn(i) = aDate;
        millis(i) = ms;
        catch
            disp('crap date');
            dbdate(i,:)
        end
    end
    return;
end
end
dbdate = deblank(dbdate);
dbdate = strrep(dbdate,'''','');
% dbdate will be in the format YYYY-MM-DD HH:MM:SS.ms which matlab doesn't understand !
YY = str2num(dbdate(1:4));
MM = str2num(dbdate(6:7));
DD = str2num(dbdate(9:10));
HH = str2num(dbdate(12:13));
M  = str2num(dbdate(15:16));
SS = str2num(dbdate(18:19));
MS = 0;
if length(dbdate) > 20;
    MS = str2num(dbdate(20:length(dbdate))); % this is read with the . so is fractional seconds
end
dn = datenum(YY,MM,DD,HH,M,SS) + MS/24/3600;
millis = MS*1000;
