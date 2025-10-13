function [data, error] = readGPLStateData(fid, fileInfo, data)
% reads trigger level binary data stored by the Click Detector.
%
% Inputs:
%   fid = file identifier
%   fileInfo = structure holding the file header, module header, a handle
%   data = a structure containing the standard data
%
% Output:
%   data = structure containing data from a single object
%

% initialize variables
error=false;
nChan = countChannels(data.channelMap);
try
    dataLength = fread(fid, 1, 'int32');
    data.baseline = fread(fid, 1, 'float32');
    data.ceilNoise = fread(fid,1, 'float32');
    data.threshFloor = fread(fid,1, 'float32');
    data.peakState = fread(fid,1,'int16');
catch mError
    disp(['Error reading ' fileInfo.fileHeader.moduleType '  data object.  Data read:']);
    disp(data);
    disp(getReport(mError));
    error=true;
end