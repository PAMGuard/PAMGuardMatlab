classdef DL < pgmatlab.core.standard.StandardAnnotation
    properties
        name = 'dlclassification';
    end

    methods (Access = private)
        function modeldata =  readModelData(~, fid)
            
            modeltype = fread(fid, 1, 'char'); % bye in Java

            isbinary = fread(fid, 1, 'char'); % bye in Java
            isbinary = isbinary~=0; % boolean is stored as byte in Java
            scale = fread(fid, 1, 'float'); % the scale for prediciton results - short in Java
            nspecies = fread(fid, 1, 'int16'); % the scale for prediciton results - short in Java
            
            % read prediciton results
            tempdata=-1*ones(length(nspecies),1);
            for j=1:nspecies
                tempdata(j) = fread(fid, 1, 'int16')/scale;
            end
            
            % get the class name IDs
            nclass = fread(fid, 1, 'int16'); % the number of class names.classnames
            classnames=-1*ones(length(nclass),1);
            for j=1:nclass
                classnames(j) = fread(fid, 1, 'int16');
            end
            
            switch (modeltype)
                
                case 0 % generic deep learning annotation
                    modeldata.predictions = tempdata;
                    modeldata.classID = classnames;
                    modeldata.isbinary = isbinary;
                    modeldata.type = modeltype;
                case 1 % Sound Spot classifier. 
                    % Sound spot
                    modeldata.predictions = tempdata;
                    modeldata.classID = classnames;
                    modeldata.isbinary = isbinary;
                    modeldata.type = modeltype;

                case 2 % dummy result
                    modeldata.predictions = []; 
                    modeldata.type = 'dummy'; 
            end
        end
    end

    methods
        function obj = DL(); end
        function [data, selState] = read(obj, fid, fileInfo, anLength, anVersion); 
            nummodels = fread(fid, 1, 'int16'); % short in Java

            % disp(['Num models: ' num2str(nummodels)])
            % read the data from each model.
            % data = zeros(1, nummodels);
            for i=1:nummodels
                data(i) = obj.readModelData(fid);
            end
        end
    end
end

