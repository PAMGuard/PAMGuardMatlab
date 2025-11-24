function [data, error] = readTritechBackground(fid, fileInfo, data)
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
fp = ftell(fid);
dataLength = fread(fid, 1, 'int32');
data.head = readTritechHeader(fid, fileInfo);
data.glf = readTritechGLFRecord(fid, fileInfo, data);


fp2 = ftell(fid);
if fp2-fp ~= dataLength
fseek(fid, fp+dataLength+4, "bof");
end

% data.firstBin = fread(fid, 1, 'int32');
% data.noiseLen = fread(fid, 1, 'int32');
% data.backGround = fread(fid, data.noiseLen, 'float32');

% initialize variables
error=false;