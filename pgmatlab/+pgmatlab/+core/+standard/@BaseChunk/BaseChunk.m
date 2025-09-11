

classdef BaseChunk
    methods
        function obj = BaseChunk(); end
        function [data, selState] = read(obj, fid, data, fileInfo, length, identifier); %#ok<INUSD>
            selState = 1;
        end
    end
end
