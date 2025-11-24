classdef GPLState < pgmatlab.core.standard.StandardModule
    properties
        objectType = [];
    end
    methods
        function obj = GPLState(); 
%             obj.background = @pgmatlab.core.modules.detectors.SpectralBackground;
        end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);
%             error = false;
%             nChan = pgmatlab.utils.countChannels(data.channelMap);
            try
%                 dataLength = fread(fid, 1, 'int32');
                data.baseline = fread(fid, 1, 'float32');
                data.ceilNoise = fread(fid,1, 'float32');
                data.threshFloor = fread(fid,1, 'float32');
                data.peakState = fread(fid,1,'int16');
            catch mError
                disp(['Error reading ' fileInfo.fileHeader.moduleType '  data object.  Data read:']);
                disp(data);
                disp(getReport(mError));
%                 error=true;
            end
        end
    end
end