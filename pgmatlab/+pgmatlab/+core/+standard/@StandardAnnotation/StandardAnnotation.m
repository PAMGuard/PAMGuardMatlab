% StandardAnnotation.m

classdef StandardAnnotation < pgmatlab.core.standard.BaseChunk
    properties (Abstract)
        name;
    end
    methods
        function obj = StandardAnnotation(); end
        function [data, selState] = read(obj, fid, fileInfo, anLength, anVersion); 
            [data, selState] = read@pgmatlab.core.standard.BaseChunk(obj, fid, fileInfo, anLength, 0);
        end
    end
end
