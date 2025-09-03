function [data] = readMatchClsfrAnnotation(fid, anId, anLength, fileInfo, anVersion)
%READMATCHCLSFRANNOTATION Read annotaitons from the matched click
%classifier.
%   The matched clcik classifier annotates click detections with a
%   threshold, matchciorr and rejectcorr value. The threshold value is used
%   in the binary classification process. If it exceeds a hard value the
%   the click is classified with the set type. The matchcorr and rejectcorr
%   values are simple the correlation values of the the match and reject
%   templates with the click repsectively.
%
%   Note: 19/11/2018 changed so can have multi template annotations. First
%   number is int16 indicating how many template results there are.

% disp(anLength);
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
