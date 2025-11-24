classdef NoiseBand < pgmatlab.core.standard.StandardModule
    properties
        objectType = 1;
    end
    methods
        function obj = NoiseBand(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);

            if (fileInfo.moduleHeader.version<=2)
                data.startSample = fread(fid, 1, 'int64');
                data.channelMap = fread(fid, 1, 'int32');
            end
            
            data.rms = fread(fid, 1, 'int16')/100.;
            data.zeroPeak = fread(fid, 1, 'int16')/100.;
            data.peakPeak = fread(fid, 1, 'int16')/100.;
            
            if (fileInfo.moduleHeader.version>=2)    
                data.sel = fread(fid, 1, 'int16')/100.;
                data.selSecs = fread(fid, 1, 'int16');
            end
        end
    end
end