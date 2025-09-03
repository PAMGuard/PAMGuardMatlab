classdef ClickClsFr < pgmatlab.core.standard.StandardAnnotation
    methods
        function obj = ClickClsFr(); end
        function [data, selState] = read(obj, fid, data, fileInfo, anLength, anVersion); 
            [data, selState] = read@pgmatlab.core.standard.StandardAnnotation(obj, fid, data, fileInfo, anLength, anVersion);
            
            nclassifications = fread(fid, 1, 'int16');
            for i = 1:nclassifications
                data.classify_set(i) = fread(fid, 1, 'int16');
            end
        end
    end
end

