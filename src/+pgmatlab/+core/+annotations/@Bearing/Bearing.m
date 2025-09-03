
classdef Bearing < pgmatlab.core.standard.StandardAnnotation
    methods
        function obj = Bearing(); end
        function [data, selState] = read(obj, fid, data, fileInfo, anLength, anVersion); 
            [data, selState] = read@pgmatlab.core.standard.StandardAnnotation(obj, fid, data, fileInfo, anLength, anVersion);
            
            data.algorithmName = pgmatlab.utils.readJavaUTFString(fid);
            data.version = annotationVersion;
            data.hydrophones = fread(fid, 1, 'uint32');
            data.arrayType = fread(fid, 1, 'int16');
            data.localisationContent = fread( fid, 1, 'uint32');
            data.nAngles = fread(fid, 1, 'int16');
            data.angles = fread(fid, data.nAngles, 'float32');
            data.nErrors = fread(fid, 1, 'int16');
            data.errors = fread(fid, data.nErrors, 'float32');
            if (annotationVersion >= 2) 
                nAng = fread(fid, 1, 'int16');
                data.refAngles = fread(fid, nAng, 'float32')
            end
        end
    end
end