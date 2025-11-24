% StandardAnnotation.m
classdef StandardAnnotation < pgmatlab.core.standard.BaseChunk
    properties (Abstract)
        name;
    end
    methods
        function obj = StandardAnnotation(); end
        %function [data, selState] = read(obj, fid, fileInfo, anLength, anVersion)
        function [data, selState] = read(obj, fid, data, fileInfo, anLength, anVersion)
            [data, selState] = read@pgmatlab.core.standard.BaseChunk(obj, fid, data, fileInfo, anLength, anVersion);
        end
    end
end
