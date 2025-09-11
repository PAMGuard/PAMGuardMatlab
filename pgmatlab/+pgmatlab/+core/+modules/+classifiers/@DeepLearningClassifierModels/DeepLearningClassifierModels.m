classdef DeepLearningClassifierModels < pgmatlab.core.standard.StandardModule
    properties
        objectType = 0;
    end
    methods
        function obj = DeepLearningClassifierModels(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);

            data.type = fread(fid, 1, 'int8');
            data.isbinary = fread(fid, 1, 'uint8=>logical');
            scale = fread(fid, 1, 'float32');
            nSpecies = fread(fid, 1, 'int16');

            %read the predictions
            for i=1:nSpecies
                pred(i) = fread(fid, 1, 'int16')/scale;
            end
            data.predictions = pred;

            %number of output classes
            nclass = fread(fid, 1, 'int16');

            if (nclass>0)
                for i=1:nclass
                    fread(fid, 1, 'int16');
                end
            end
        end
    end
end