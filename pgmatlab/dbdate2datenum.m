function [dn millis] = dbdate2datenum(dbdate)
% function dn = dbdate2datenum(dbdate)
%  converts a YYYY-MM-DD HH:MM:SS.ms datestring returned from a database
%  into a datenum (standard Matlab time)
  if iscell(dbdate)
    n = length(dbdate);
    for i = 1:n
        [aDate, ms] = dbdate2datenum(dbdate{i});
      dn(i) = aDate;
          millis(i) = ms;
    end
    return;
  end
    
  dbdate = deblank(dbdate);
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
  