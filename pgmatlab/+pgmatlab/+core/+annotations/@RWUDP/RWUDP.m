classdef RWUDP < pgmatlab.core.standard.StandardAnnotation
    methods
        function obj = RWUDP(); end
        function [data, selState] = read(obj, fid, data, fileInfo, anLength, anVersion); 
            [data, selState] = read@pgmatlab.core.standard.StandardAnnotation(obj, fid, data, fileInfo, anLength, anVersion);
            
            data.label = pgmatlab.utils.readJavaUTFString(fid);
            data.method = pgmatlab.utils.readJavaUTFString(fid);
            data.score = fread(fid, 1, 'float32');
        end
    end
end



