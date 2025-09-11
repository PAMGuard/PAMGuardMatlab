function [data, error] = readDifarData(fid, fileInfo, data)
% reads binary data stored by the Difar module.
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
%     timeMillis = dis.readLong();
%     parentUID = dis.readLong();
%     ipi = dis.readDouble();
%     ipiAmplitude = dis.readDouble();
%     sampleRate = dis.readFloat();
%     maxVal = dis.readFloat();
%     cepLength = dis.readInt();
%     if (cepLength>0) {
%         echoData = new double[cepLength];
%         for (int i = 0; i < echoData.length; i++) {
%             echoData[i] = dis.readShort() * maxVal / 32767;
%         }
%     }
    % read module specific data
    dataLength = fread(fid, 1, 'int32');
    if (dataLength==0)
        return;
    end

    data.parentUID = fread(fid, 1, 'int64');            % 8
    data.ipi = fread(fid,1,'float');                    % 4
    data.ipiAmplitude = fread(fid,1,'float');           % 4
    data.sampleRate = fread(fid,1,'float');             % 4
    data.maxVal = fread(fid,1,'float');                 % 4
    data.echoLen = fread(fid, 1, 'int32');              % 4
    data.echoData = fread(fid, data.echoLen, 'int16')...
                        * data.maxVal / 32767;          % len * 2
    
catch mError
    disp(['Error reading ' fileInfo.fileHeader.moduleType '  data object.  Data read:']);
    disp(data);
    disp(getReport(mError));
    error=true;
end
