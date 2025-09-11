classdef LongTermSpectralAverageHeader < pgmatlab.core.standard.StandardModuleHeader
    methods
        function obj = LongTermSpectralAverageHeader(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier);

            if (data.binaryLength ~= 0)
                data.fftLength = fread(fid, 1, 'int32');
                data.fftHop = fread(fid, 1, 'int32');
                data.intervalSeconds = fread(fid, 1, 'int32');
            end
        end
    end
end