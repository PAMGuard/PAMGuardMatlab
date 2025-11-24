classdef TDBL < pgmatlab.core.standard.StandardAnnotation
    properties
        name = 'TDBL';
    end
    methods
        function obj = TDBL(); end
        function [data, selState] = read(obj, fid, data, fileInfo, anLength, anVersion)
            [data, selState] = read@pgmatlab.core.standard.StandardAnnotation(obj, fid, data, fileInfo, anLength, anVersion);

            nAngles = fread(fid, 1, 'int16');
            data.angles = fread(fid, nAngles, 'float32');
            nErrors = fread(fid, 1, 'int16');
            data.angleErrors = fread(fid, nErrors, 'float32');
        end
    end
end
