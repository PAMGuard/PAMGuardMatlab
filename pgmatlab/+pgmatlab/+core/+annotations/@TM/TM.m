classdef TM < pgmatlab.core.standard.StandardAnnotation
    properties
        name = 'TargetMotion';
    end
    methods
        function obj = TM(); end
        function [data, selState] = read(obj, fid, data, fileInfo, anLength, anVersion)
            [data, selState] = read@pgmatlab.core.standard.StandardAnnotation(obj, fid, data, fileInfo, anLength, anVersion);

            data.model = pgmatlab.utils.readJavaUTFString(fid);
            data.nLocations = fread(fid, 1, 'int16');
            data.hydrophones = fread(fid, 1, 'uint32');
            for i = 1:data.nLocations
                loc.latitude = fread(fid, 1, 'float64');
                loc.longitude = fread(fid, 1, 'float64');
                loc.height = fread(fid, 1, 'float32');
                loc.error = pgmatlab.utils.readJavaUTFString(fid);
                data.loc(i) = loc;
            end
        end
    end
end
