function [data, error] = readGPLDetections(fid, fileInfo, data)
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

% initialize variables
error=false;

try
    
    % read module specific data
%     skipdummy = fread(fid, 1, 'int32');
    dataLength = fread(fid, 1, 'int32');
    if (dataLength==0)
        return;
    end
    
    data.timeRes = fread(fid, 1, 'float32');
    data.freqRes = fread(fid, 1, 'float32');
    data.area = fread(fid, 1, 'int16');
    bitDepth = fread(fid, 1, 'int8');
    if (bitDepth == 8) 
        pType = 'uint8';
    else
        pType = 'uint16';
    end
    points = zeros(2,data.area,pType);
    excess = zeros(1,data.area,'single');
    energy = zeros(1,data.area,'single');
    for i = 1:data.area
       points(:,i) = fread(fid, 2, pType);
       excess(i) = fread(fid, 1, 'float32');
       energy(i) = fread(fid, 1, 'float32');
    end
    data.points = points;
    data.excess = excess;
    data.energy = energy;

    
catch mError
    disp(['Error reading ' fileInfo.fileHeader.moduleType '  data object.  Data read:']);
    disp(data);
    disp(getReport(mError));
    error=true;
end
