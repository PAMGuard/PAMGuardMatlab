classdef RWUDP < StandardAnnotation
    methods
        function obj = RWUDP(); end
        function [data, selState] = read(obj, fid, data, fileInfo, anLength, anVersion); 
            [data, selState] = read@StandardAnnotation(obj, fid, data, fileInfo, anLength, anVersion);
            
            data.label = readJavaUTFString(fid);
            data.method = readJavaUTFString(fid);
            data.score = fread(fid, 1, 'float32');
        end
    end
end



