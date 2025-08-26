% StandardAnnotation.m

classdef StandardAnnotation < BaseChunk
    properties (Abstract)
        name;
    end
    methods
        function obj = BaseChunk(); end
        function [data, selState] = read(obj, fid, fileInfo, anLength, anVersion); 
            [data, selState] = read@BaseChunk(obj, fid, fileInfo, anLength, 0);
        end
    end
end
