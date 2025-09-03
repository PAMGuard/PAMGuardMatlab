classdef DbHt < pgmatlab.core.standard.StandardModule
    properties
        objectType = 1;
    end
    methods
        function obj = DbHt(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);

            if (fileInfo.moduleHeader.version <= 1)
                data.startSample = fread(fid, 1, 'int64');
                data.channelMap = fread(fid, 1, 'int32');
            end
            
            data.rms = fread(fid, 1, 'int16')/100;
            data.zeroPeak = fread(fid, 1, 'int16')/100;
            data.peakPeak = fread(fid, 1, 'int16')/100;
        end
    end
end