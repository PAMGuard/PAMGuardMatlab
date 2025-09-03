classdef UserForm < pgmatlab.core.standard.StandardAnnotation
    methods
        function obj = UserForm(); end
        function [data, selState] = read(obj, fid, data, fileInfo, anLength, anVersion); 
            [data, selState] = read@pgmatlab.core.standard.StandardAnnotation(obj, fid, data, fileInfo, anLength, anVersion);
            
            % this is not quite right...
            txtLen = anLength-length(anId)-2-2;
            data = fread(fid, txtLen, 'char')';
            data = char(data);
        end
    end
end
