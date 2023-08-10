function [data background] = loadPamguardBinaryFolder(dir, fileMask, verbose, filterfun)
% load all data from a folder and it's sub folders
%  data = loadPamguardBinaryFolder(dir, fileMask, verbose) loads all data from 
% the folder dir where files satisfy the fileMask. All files must
% contain data of the same format so mask must specify a particular type 
% of data file, e.g. clicks*.pgdf. If verbose is a non-zero number 'n' then
% every n files a progress message will be printed on the temrinal. 
%
% e.g. allclicks = loadPAMFolder('C:/Mydata', 'Click_Detector_*.pgdf', 5);
%
if (nargin < 3)
    verbose = 0;
end
if nargin < 4
    filterfun = @passalldata;
end
data = [];
background = [];
d = dirsub(dir, fileMask);
for i = 1:numel(d)
    if verbose
        if mod(i, verbose) == 0
            fprintf('Loading %d/%d (%d) %s\n', i, numel(d), numel(data), d(i).name);
        end
    end
    [fRoot, fName, fEnd] = fileparts(d(i).name);
    fileNameOnly = [fName fEnd];
    [dat fInf] = loadPamguardBinaryFile(d(i).name, 'filter', filterfun);
    if ~isempty(dat)
        % need to add bookkeeping data to dat so that we know which file
        % each click comes from and also know which click it is within the
        % file. 
        for iDat = 1:numel(dat)
            dat(iDat).clickNumber = iDat;
            dat(iDat).fileName = fileNameOnly;
        end
        data = [data dat];
    end
    if isfield(fInf, 'background')
        background = [background fInf.background];
    end
end
    