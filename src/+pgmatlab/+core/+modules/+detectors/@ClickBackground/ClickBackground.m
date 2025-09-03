classdef ClickBackground < pgmatlab.core.standard.StandardBackground
    methods
        function obj = ClickBackground(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);            
            data.noiseLen = fread(fid, 1, 'int16');
            data.backGround = fread(fid, data.noiseLen, 'float32');
        end
    end
end