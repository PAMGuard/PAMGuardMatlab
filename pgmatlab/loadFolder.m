function data = loadFolder(dir, fileMask, verbose)
% load all data from a folder and it's sub folders
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