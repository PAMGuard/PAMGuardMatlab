function [data, error] = readClickBackground(fid, fileInfo, data)

% initialize variables
error=false;

dataLength = fread(fid, 1, 'int32');
data.noiseLen = fread(fid, 1, 'int16');
data.backGround = fread(fid, data.noiseLen, 'float32');