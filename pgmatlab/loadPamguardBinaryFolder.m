function [data, background] = loadPamguardBinaryFolder(dir, fileMask, verbose, varargin)

% load all data from a folder and it's sub folders
%  data = loadPamguardBinaryFolder(dir, fileMask, verbose) loads all data from
% the folder dir where files satisfy the fileMask. All files must
% contain data of the same format so mask must specify a particular type
% of data file, e.g. clicks*.pgdf. If verbose is a non-zero number 'n' then
% every n files a progress message will be printed on the temrinal.
%
% e.g. allclicks = loadPamguardBinaryFolder('C:/Mydata', 'Click_Detector_*.pgdf', 5);
%
if (nargin < 3)
    verbose = 2;
end

timesonly=false;
if nargin<4
    iArg = 0;
    while iArg < numel(varargin)
        iArg = iArg + 1;
        switch(varargin{iArg})
            case 'timesonly'
                iArg = iArg + 1;
                timesonly = varargin{iArg};
        end
    end
    
else
    % need to do this so that varargin is successfully passed to new
    % function
    %     varargin = varargin(1:end);
end
data = [];
background = [];
d = dirsub(dir, fileMask);
for i = 1:numel(d)
    %     disp(d(i).name);
    if verbose
        if mod(i, verbose) == 0
            fprintf('Loading %d/%d (%d) %s\n', i, numel(d), numel(data), d(i).name);
        end
    end
    % need to use varargin{:} to pass arguments from one function to
    % another for some reason.
    [dat, fInf] = loadPamguardBinaryFile(d(i).name, varargin{:});
    disp(['Loaded ' num2str(length(data)) ' detections' ])
    if timesonly
        dat = [[dat.UID]; [dat.date]; [dat.type]]; %dates are accurate to 10us
    end
    

    if ~isempty(dat)
        data = [data dat];
    end

    if isfield(fInf, 'background')
        background = [background fInf.background];
    end
end
