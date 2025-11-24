classdef GPL < pgmatlab.core.standard.StandardModule
    properties
        objectType = [];
    end
    methods
        function obj = GPL(); 
            obj.background = @pgmatlab.core.modules.detectors.SpectralBackground;
        end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);
            data.timeRes = fread(fid, 1, 'float32');
            data.freqRes = fread(fid, 1, 'float32');
            data.area = fread(fid, 1, 'int16');
            bitDepth = fread(fid, 1, 'int8');
            if (bitDepth == 8) 
                pType = 'uint8';
            else
                pType = 'uint16';
            end
            points = zeros(2,data.area,pType);
            excess = zeros(1,data.area,'single');
            energy = zeros(1,data.area,'single');
            for i = 1:data.area
                points(:,i) = fread(fid, 2, pType);
                excess(i) = fread(fid, 1, 'float32');
                energy(i) = fread(fid, 1, 'float32');
            end
            data.points = points;
            data.excess = excess;
            data.energy = energy;
        end
    end
end