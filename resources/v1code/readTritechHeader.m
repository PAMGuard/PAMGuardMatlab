function [head, error] = readTritechBackground(fid, fileInfo)
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
    

% note that data have been written in Tritech file structures which 
% are little endien. PAMGuard files are big endien, so need to convert as
% we read. 
% read the generic header. 
endy = 'ieee-le';
head.m_idChar = fread(fid, 1, 'uint8', endy);
head.m_version = fread(fid, 1, 'uint8', endy);
head.m_length = fread(fid, 1, 'uint32', endy);
head.m_timestamp = fread(fid, 1, 'double', endy);
head.m_dataType = fread(fid, 1, 'uint8', endy);
head.tm_deviceId = fread(fid, 1, 'uint16', endy);
head.m_node_ID = fread(fid, 1, 'uint16', endy);
head.spare = fread(fid, 1, 'uint16');

error = false;