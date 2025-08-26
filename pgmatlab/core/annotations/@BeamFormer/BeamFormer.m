
classdef BeamFormer < StandardAnnotation
    methods
        function obj = BeamFormer(); end
        function [data, selState] = read(obj, fid, data, fileInfo, anLength, anVersion); 
            [data, selState] = read@StandardAnnotation(obj, fid, data, fileInfo, anLength, anVersion);
            
            data.hydrophones = fread(fid, 1, 'uint32');
            data.arrayType = fread(fid, 1, 'int16');
            data.localisationContent = fread( fid, 1, 'uint32');
            data.nAngles = fread(fid, 1, 'int16');
            data.angles = fread(fid, data.nAngles, 'float32');
        end
    end
end