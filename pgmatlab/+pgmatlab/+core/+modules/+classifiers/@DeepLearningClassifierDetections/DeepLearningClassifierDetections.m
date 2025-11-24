classdef DeepLearningClassifierDetections < pgmatlab.core.standard.StandardModule
    properties
        objectType = 1;
    end
    methods
        function obj = DeepLearningClassifierDetections(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);

            data.nChan = fread(fid, 1, 'int16');
            data.nSamps = fread(fid, 1, 'int32');
            data.scale = 1/fread(fid, 1, 'float');
            data.wave = fread(fid, [data.nSamps,data.nChan], 'int8')/ data.scale;
        end
    end
end