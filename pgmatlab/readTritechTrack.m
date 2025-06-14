function [data, error] = readTritechTrack(fid, fileInfo, data)
% [data, error] = readTritechTrack(fid, fileInfo, data)
%
% reader for tritech track data (not a standard PAMGuard module)

error = false;

try 

    dataLength = fread(fid, 1, 'int32');

    data.nPoints = fread(fid, 1, 'int32');
    data.nSonar = fread(fid, 1, 'int8');
    data.sonarIds = fread(fid, data.nSonar, 'int16');
    dum = fread(fid,3,'float32');
    % data.straightLength = fread(fid, 1, 'float32');
    % data.wobblyLength = fread(fid, 1, 'float32');
    % data.meanOccupancy = fread(fid, 1, 'float32');
    data.straightLength = dum(1);
    data.wobblyLength = dum(2);
    data.meanOccupancy = dum(3);
    data.timeMillis = zeros(1, data.nPoints);
    data.sonarId = zeros(1, data.nPoints);
    data.minBearing = zeros(1, data.nPoints);
    data.maxBearing = zeros(1, data.nPoints);
    data.peakBearing = zeros(1, data.nPoints);
    data.minRange = zeros(1, data.nPoints);
    data.maxRange = zeros(1, data.nPoints);
    data.peakRange = zeros(1, data.nPoints);
    data.objSize = zeros(1, data.nPoints);
    data.occupancy = zeros(1, data.nPoints);
    data.aveValue = zeros(1, data.nPoints);
    data.totValue = zeros(1, data.nPoints);
    data.maxValue = zeros(1, data.nPoints);
    for i = 1:data.nPoints
        data.timeMillis(i) = fread(fid, 1, 'int64');
        data.sonarId(i) = fread(fid, 1, 'int16');
        % data.minBearing(i) = fread(fid, 1, 'float32');
        % data.maxBearing(i) = fread(fid, 1, 'float32');
        % data.peakBearing(i) = fread(fid, 1, 'float32');
        % data.minRange(i) = fread(fid, 1, 'float32');
        % data.maxRange(i) = fread(fid, 1, 'float32');
        % data.peakRange(i) = fread(fid, 1, 'float32');
        % data.objSize(i) = fread(fid, 1, 'float32');
        % data.occupancy(i) = fread(fid, 1, 'float32');
        fDum = fread(fid,8,'float32');
        data.minBearing(i) = fDum(1);
        data.maxBearing(i) = fDum(2);
        data.peakBearing(i) = fDum(3);
        data.minRange(i) = fDum(4);
        data.maxRange(i) = fDum(5);
        data.peakRange(i) = fDum(6);
        data.objSize(i) = fDum(7);
        data.occupancy(i) = fDum(8);

        data.aveValue(i) = fread(fid, 1, 'int16');
        data.totValue(i) = fread(fid, 1, 'int32');
        data.maxValue(i) = fread(fid, 1, 'int16');
    end
    data.dates = millisToDateNum(data.timeMillis);

catch mError
    disp(['Error reading ' fileInfo.fileHeader.moduleType '  data object.  Data read:']);
    disp(data);
    disp(getReport(mError));
    error=true;
end