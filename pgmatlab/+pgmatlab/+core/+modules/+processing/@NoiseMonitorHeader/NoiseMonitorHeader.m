classdef NoiseMonitorHeader < pgmatlab.core.standard.StandardModuleHeader
    methods
        function obj = NoiseMonitorHeader(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier);

            if (data.binaryLength~=0)
                data.nBands = fread(fid, 1, 'int16');
                data.statsTypes = fread(fid, 1, 'int16');
                data.loEdges = fread(fid, data.nBands, 'float');
                data.hiEdges = fread(fid, data.nBands, 'float');
            end
        end
    end
end