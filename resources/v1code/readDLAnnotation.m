function [modeldatas] = readDLAnnotation(fid, anId, anLength, fileInfo, anVersion)
%READDLANNOTAION - read a deep learning annotation from PAMGuard.


nummodels = fread(fid, 1, 'int16'); % short in Java

% disp(['Num models: ' num2str(nummodels)])
% read the data from each model.
for i=1:nummodels
    modeldatas(i) = readModelData(fid);
end


    function modeldata =  readModelData(fid)
        
        modeltype = fread(fid, 1, 'char'); % bye in Java
%         disp(['Model type: ' num2str(modeltype)])

        isbinary = fread(fid, 1, 'char'); % bye in Java
        isbinary = isbinary~=0; % boolean is stored as byte in Java
        scale = fread(fid, 1, 'float'); % the scale for prediciton results - short in Java
        nspecies = fread(fid, 1, 'int16'); % the scale for prediciton results - short in Java
        
        % read prediciton results
        data=-1*ones(length(nspecies),1);
        for j=1:nspecies
            data(j) = fread(fid, 1, 'int16')/scale;
        end
        
        % get the class name IDs
        nclass = fread(fid, 1, 'int16'); % the number of class names.classnames
        classnames=-1*ones(length(nclass),1);
        for j=1:nclass
            classnames(j) = fread(fid, 1, 'int16');
        end
        
        switch (modeltype)
            
            case 0 % generic deep learning annotation
                modeldata.predictions = data;
                modeldata.classID = classnames;
                modeldata.isbinary = isbinary;
                modeldata.type = modeltype;
            case 1 % Sound Spot classifier. 
                % Sound spot
                modeldata.predictions = data;
                modeldata.classID = classnames;
                modeldata.isbinary = isbinary;
                modeldata.type = modeltype;

            case 2 % dummy result
                modeldata.predictions = []; 
                modeldata.type = 'dummy'; 
        end
    end
end