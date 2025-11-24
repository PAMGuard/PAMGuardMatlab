function millis = dateNumToMillis(datenum)
%dateNumToMillis - convert a matlab date (days since 00-Jan-0000) to a time
%in Java milliseconds (milliseconds since 00-Jan-1970)
%
%   Syntax:
%       javamillis = dateNumToMillis(matlabdatenum)

millis = (datenum-719529)*86400000;
% datenum = double(millis)/86400000.0+719529;