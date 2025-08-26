function data = loadPAMFolder(dir, fileMask, verbose)
% load all data from a folder and it's sub folders
%  data = loadFolder(dir, fileMask, verbose) loads all data from 
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
data = [];
d = dirsub(dir, fileMask);
for i = 1:numel(d)
    if verbose
        if mod(i, verbose) == 0
            fprintf('Loading %s\n', d(i).name);
        end
    end
    dat = loadPamguardBinaryFile(d(i).name);
    if ~isempty(dat)
        data = [data dat];
    end
end
    