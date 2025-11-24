classdef IshmaelDetections < pgmatlab.core.standard.StandardModule
    properties
        objectType = [];
    end
    methods
        function obj = IshmaelDetections(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);
        end
    end
end