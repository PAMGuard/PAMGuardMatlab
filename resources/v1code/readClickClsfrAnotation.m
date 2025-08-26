function clkclsfrAnnotation = readClickClsfrAnotation(fid, anId, anLength, fileInfo, anVersion)
%READCLICKCLLSSFRANOTATION Read the click classifier annotation
%   The click classifier annotation is from the click detector and returns
%   a list of the classifiers (represented by click type flag) which the
%   click passed. The type flag in the click will be the first classifier
%   which the click passed in the list. 

% disp('Hello clk classifier')


nclassifications = fread(fid, 1, 'int16');
for i = 1:nclassifications
    clkclsfrAnnotation.classify_set(i) = fread(fid, 1, 'int16');
end

% disp(['Number of classification pass: ' num2str(nclassifications)])

end

