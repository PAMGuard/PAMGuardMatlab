
classdef BeamFormer < pgmatlab.core.standard.StandardAnnotation
    properties
        name = "BeamFormer"
    end
    methods
        function obj = BeamFormer(); end
        function [data, selState] = read(obj, fid, data, fileInfo, anLength, anVersion); 
            [data, selState] = read@pgmatlab.core.standard.StandardAnnotation(obj, fid, data, fileInfo, anLength, anVersion);
            
            data.hydrophones = fread(fid, 1, 'uint32');
            data.arrayType = fread(fid, 1, 'int16');
            data.localisationContent = fread( fid, 1, 'uint32');
            data.nAngles = fread(fid, 1, 'int16');
            data.angles = fread(fid, data.nAngles, 'float32');
        end
    end
end