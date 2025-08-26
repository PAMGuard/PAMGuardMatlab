function [data, error] = readDLModelData(fid, fileInfo, data)
% Reads binary data stored by the Deep learning module. This is the a time
% series of all prediciton i.e. not detections which have passed a decision
% threshold. 
%
% Inputs:
%   fid = file identifier
%   fileInfo = structure holding the file header, module header, a handle
%   data = a structure containing the standard data
%
% Output:
%   data = structure containing data from a single object\


% initialize variables
error=false;

try

    % read prediciton settings
    dataLength = fread(fid, 1, 'int32');
    if (dataLength==0)
        return;
    end
    data.type = fread(fid, 1, 'int8');
    data.isbinary = fread(fid, 1, 'uint8=>logical');
    scale = fread(fid, 1, 'float32');
    nSpecies = fread(fid, 1, 'int16');

    %read the predictions
    for i=1:nSpecies
        pred(i) = fread(fid, 1, 'int16')/scale;
    end
    data.predictions = pred;

    %number of output classes
    nclass = fread(fid, 1, 'int16');

    if (nclass>0)
    for i=1:nclass
        fread(fid, 1, 'int16');
    end
    end


catch mError
    disp(['Error reading ' fileInfo.fileHeader.moduleType '  data object.  Data read:']);
    disp(data);
    disp(getReport(mError));
    error=true;
end

