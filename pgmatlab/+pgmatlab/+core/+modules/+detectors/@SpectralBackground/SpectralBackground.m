classdef SpectralBackground < pgmatlab.core.standard.StandardBackground
    methods
        function obj = SpectralBackground(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);
            data.firstBin = fread(fid, 1, 'int32');
            data.noiseLen = fread(fid, 1, 'int32');
            data.backGround = fread(fid, data.noiseLen, 'float32');
        end
    end
end