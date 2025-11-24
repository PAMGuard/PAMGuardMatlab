function [data, error] = readSpectralBackground(fid, fileInfo, data)
% reads binary data stored by the GPL Detector.
%
% Inputs:
%   fid = file identifier
%   fileInfo = structure holding the file header, module header, a handle
%   data = a structure containing the standard data
%
% Output:
%   data = structure containing data from a single object
%
% for i = 1:20
%     fread(fid, 1, 'int16')
% end
%     skipdummy = fread(fid, 1, 'int32');
    dataLength = fread(fid, 1, 'int32');
data.firstBin = fread(fid, 1, 'int32');
data.noiseLen = fread(fid, 1, 'int32');
data.backGround = fread(fid, data.noiseLen, 'float32');

% initialize variables
error=false;