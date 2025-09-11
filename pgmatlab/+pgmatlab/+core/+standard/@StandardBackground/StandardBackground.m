% StandarFileHeader.m

classdef StandardBackground < pgmatlab.core.standard.BaseChunk
    methods
        function obj = StandardBackground(); end
        function [data, selState] = read(obj, fid, data, fileInfo, length, identifier, selState) 
            [data, selState] = obj.readImpl(fid, data, fileInfo, length, identifier, selState);
        end
    end
end
