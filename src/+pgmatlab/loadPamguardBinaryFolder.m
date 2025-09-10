function [allData, allBackground, fileInfos] = loadPamguardBinaryFolder(dir, fileMask, verbose, filterfun, varargin)
%PGMATLAB.LOADPAMGUARDBINARYFOLDER - Load many <a href="https://www.pam
%   guard.org/olhelp/utilities/BinaryStore/docs/binarystore_overview.ht
%   ml">PAMGuard Binary Files</a> into memory from a folder (and subfol
%   ders).
%
%   Produces a 1x3 vector with the datasets, backgrounds, and fileInfos
%   from all of the files in the folder.
%
%   Syntax:
%       [allData, allBackground, fileInfos] = PGMATLAB.LOADPAMGUARDBINARYFOLDER(dir, fileMask, verbose, filterfun, varargin)
%       [allData, allBackground] = PGMATLAB.LOADPAMGUARDBINARYFOLDER(dir, fileMask, verbose, filterfun, varargin)
%       allData = PGMATLAB.LOADPAMGUARDBINARYFOLDER(dir, fileMask, verbose, filterfun, varargin)
%   
%       - dir (string, required) is the root directory of the binary data files to be read.
%       
%       - fileMask (string, required) is a file mask used to select the files in dir (e.g. "*.pgdf").
%       
%       - verbose (integer, default 0) if a non-zero number n then every n files prints a progress log.
%           To avoid logging set verbose to 0.
%       
%       - filterfun (function, default 0) Specify a filter function to apply to the data.
%           Must be a function handle that takes a data struct as input and
%           returns a selection state (0 = skip, 1 = keep, 2 = stop, if data
%           is ordered). If you want to bypass this variable, simply pass 0
%           or an empty function handle.
%
%       - varargin (optional) can be one or more of the following options, used to filter data:
%
%           'timerange', TIME_RANGE (default ALL): Specify the time range to load data from.
%               TIME_RANGE is a 1x2 vector of the form [START_TIME, END_TIME].
%
%           'uidrange', UID_RANGE (default ALL): Specify the UID range to load data from.
%               UID_RANGE is a 1x2 vector of the form [START_UID, END_UID].
%
%           'uidlist', UID_LIST (default ALL): Specify a list of UIDs to load data from.
%               UID_LIST is a vector of UIDs.
%
%           'channel', CHANNEL_MAP (default ALL): Specify a channel map to apply to the data.
%               CHANNEL_MAP a bitmap of the channels to load.
%
%           'sorted', SORTED (default 0): Specify whether the data is sorted. SORTED is a 
%               logical value (1 true or 0 false). It serves to speed up execution
%               if the data exceeds the upper bound of a range filter. This applies
%               if 'timerange' and/or 'uidrange' are provided. Setting SORTED to 1
%               when using these range filters can cause unexpected behaviour if the
%               data being filtered on is not actually sorted. Defaults to 0 (false).
%               SORTED also requires files to be alphanumerically sorted in the folder
%               bring read.
%
%   Example 1: load an entire folder of binary files
%       >>> [d,b,f] = pgmatlab.loadPamguardBinaryFolder("./Data");
%
%   Example 2: load an entire folder of binary files with a filterfun
%       >>> function selState = myFilter(data)
%               % remove all data where type ~= 1
%               if data.type == 1
%                   selState = 1; % keep
%               else
%                   selState = 0; % skip
%               end
%       >>> end
%       >>> [d,b,f] = pgmatlab.loadPamguardBinaryFolder("./Data", "*.pgdf", 1, @myFilter)
%
%   Example 3: load an entire folder of binary files within a specific time range (indicating sorted data);
%       >>> startTime = datenum(2017,10,21,0,25,0);
%       >>> endTime = datenum(2017,10,21,0,26,0);
%       >>> [d,b,f] = pgmatlab.loadPamguardBinaryFile("./Data.pgdf", "*.pgdf", 1, @pgmatlab.utils.passalldata, "timerange", [startTime endTime], "sorted", 1)
%   
%   For more examples on how to use varargin to specify filters, check out help PGMATLAB.LOADPAMGUARDBINARYFILE.
%
%   See also PGMATLAB.LOADPAMGUARDBINARYFILE, PGMATLAB.LOADPAMGUARDBINARYFOLDER.
%

% Set default verbosity
if (nargin < 3)
    verbose = 0;
end

% Set default varargin variable
iArg = length(varargin);
if iArg == 0
    varargin = {};
end

% Manually add filter to the varargin. This is to
% support legacy code, and should be discouraged.
if nargin < 4 || (nargin >= 4 && ~filterfun)
    filterfun = @pgmatlab.utils.passalldata;
end
varargin{iArg + 1} = "filter";
varargin{iArg + 2} = filterfun;

allData = [];
nData = 0;
allBackground = [];
nBackground = 0;    

allFiles = pgmatlab.utils.dirsub(dir, fileMask);
fileInfos = [];
nFileInfos = 0;

for i = 1:numel(allFiles)
    % Which file is going to be loaded
    [fDir, fName, fEnd] = fileparts(allFiles(i).name);
    fileName = [fName fEnd];

    % Print log message based on verbosity
    if verbose
        if mod(i, verbose) == 0
            fprintf('Loading %d/%d (%d) %s%s (%s)\n', i, numel(allFiles), numel(allData), fName, fEnd, fDir);
        end
    end

    % Load binary file data
    [data, fileInfo, selState] = pgmatlab.loadPamguardBinaryFile(allFiles(i).name, varargin{:});
    
    % Populate allData array is necessary
    if ~isempty(data)
        for j = 1:numel(data)
            data(j).clickNumber = j; % DEPRACATED: use uid instead of clickNumber to track specific nodes
            data(j).fileName = fileName;
        end
        allData = [pgmatlab.utils.checkArrayAllocation(allData, nData + length(data), data(1)) data];
        nData = nData + length(data);
    end

    % Populate allBackground array if necessary
    if isfield(fileInfo, 'background') && nargout >= 2
        allBackground = [pgmatlab.utils.checkArrayAllocation(allBackground, nBackground + length(fileInfo.background), -1) fileInfo.background];
        nBackground = nBackground + length(fileInfo.background);
    end

    % Populate fileInfo array if necessary
    if nargout >= 3
        fileInfos = pgmatlab.utils.checkArrayAllocation(fileInfos, numel(allFiles), fileInfo);
        fileInfos(i) = fileInfo;
        nFileInfos = nFileInfos + 1;
    end

    % Selection state of 2 means the data has surpassed the upper
    % boundary of a particular range (usually time or uid). This
    % means that we can stop searching files.
    if selState == 2
        break;
    end
end

% Ensure addData, allBackground and fileInfos are the
% correct size. Due to preallocation, they are likely
% to have exceeded the expected length.
if nData > 0
    allData = allData(1:nData);
end
if nBackground > 0
    allBackground = allBackground(1:nBackground);
end
if nFileInfos >0
    fileInfos = fileInfos(1:nFileInfos);
end