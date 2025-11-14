classdef MatchCls < pgmatlab.core.standard.StandardAnnotation
    properties
        name = 'MatchCls';
    end
    methods
        function obj = MatchCls(); end
        function [data, selState] = read(obj, fid, data, fileInfo, anLength, anVersion) 
            [data, selState] = read@pgmatlab.core.standard.StandardAnnotation(obj, fid, data, fileInfo, anLength, anVersion);
            
            if (anVersion==1)
                    %the threshold value. This is used to classify the clicks.
                threshold = fread(fid, 1, 'double');
            
                %the maximum correlation between the match template and the click
                matchcorr = fread(fid, 1, 'double');
                
                %the max correlation value between the reject template and the click.
                rejectcorr = fread(fid, 1, 'double');
                
                data = [threshold matchcorr rejectcorr]; 
                
            end

            % new version with multiple templates. 
            if (anVersion==2)
                %read the number of templates there are
                ntemplates = fread(fid, 1, 'int16'); % short in Java

                n=1; 
                data=zeros(ntemplates,3); % pre allocate the data array, 
                for i=1:ntemplates
                    
                    %the threshold value. This is used to classify the clicks.
                    threshold = fread(fid, 1, 'double');
                    
                    %the maximum correlation between the match template and the click
                    matchcorr = fread(fid, 1, 'double');
                    
                    %the max correlation value between the reject template and the click.
                    rejectcorr = fread(fid, 1, 'double');
                    
                    data(n,1)   =   threshold;
                    data(n,2)   =   matchcorr;
                    data(n,3)   =   rejectcorr;
                    n=n+1; 
                    
                end
            end
        end
    end
end



