classdef NoiseMonitor < pgmatlab.core.standard.StandardModule
    properties
        objectType = 1;
    end
    methods
        function obj = NoiseMonitor();
            obj.header = @pgmatlab.core.modules.processing.NoiseMonitorHeader;
        end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);

            data.iChan = fread(fid, 1, 'int16');
            data.nBands = fread(fid, 1, 'int16');
            
            if (fileInfo.moduleHeader.version>=1)    
                data.nMeasures = fread(fid, 1, 'int16');
            else
                data.nMeasures = 4;
            end
            
            if (fileInfo.moduleHeader.version<=1)
                n = fread(fid, data.nBands*data.nMeasures, 'float');
            else
                n = fread(fid, data.nBands*data.nMeasures, 'int16') / 100.;
            end
            data.noise = reshape(n, data.nMeasures, data.nBands);
        end
    end
end