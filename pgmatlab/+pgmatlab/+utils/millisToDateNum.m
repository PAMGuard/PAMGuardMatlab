function datenum = millisToDateNum(millis)
%dateNumToMillis - convert a time in Java milliseconds (millis since 1970)
%into a Matlab date (days since 00-Jan-0000)
%
%   Syntax:
%       matlabdate = millisToDateNum(javamillis)

datenum = double(millis)/double(86400000.0)+double(719529);