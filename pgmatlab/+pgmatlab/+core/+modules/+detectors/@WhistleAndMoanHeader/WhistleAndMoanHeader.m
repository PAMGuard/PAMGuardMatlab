classdef WhistleAndMoanHeader < pgmatlab.core.standard.StandardModuleHeader
    methods
        function obj = WhistleAndMoanHeader(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier);
            if (data.binaryLength~=0 && data.version>=1)
                data.delayScale = fread(fid, 1, 'int32');
            end
        end
    end
end