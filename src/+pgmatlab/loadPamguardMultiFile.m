function eventData = loadPamguardMultiFile(dir, fileNames, UIDs, verbose)
%PGMATLAB.LOADPAMGUARDMULTIFILE - Load multiple <a href="https://www.pamgu
%   ard.org/olhelp/utilities/BinaryStore/docs/binarystore_overview.html">P
%   AMGuard Binary Files</a> into memory filtering by certain UIDs in certain
%   files.
%
%   This can be used to get binary file data for data associated with PAMGuard
%   events. In other words, PGMATLAB.LOADPAMGUARDMULTIFILE is a bulk-load 
%   function with file-specific UID filters.
%
%   Produces an array of data points which correspond to the UID filters from
%   multiple binary files.  
%
%   Syntax:
%       eventData = PGMATLAB.LOADPAMGUARDMULTIFILE(dir, fileNames, UIDs, verbose);
%   
%       - dir (string, required): the root directory in which to search for
%           PAMGuard binary files (.pgdf).
%
%       - fileNames (array) and UIDs (array): two parallel arrays specifying
%           specific UIDs in each file to load into eventData. See Examples for
%           more information on how these arrays interact with each other.
%
%   Example 1: Load sample event
%       fileNames = {'file1.pgdf', 'file2.pgdf'];
%       uids = [500001, 500002];
%       pgmatlab.loadPamguardMultiFile('./path/to/dir', fileNames, uids);
%
%   Example 2: Load sample event with logging verbosity
%       fileNames = {'file1.pgdf', 'file2.pgdf'];
%       uids = [500001, 500002];
%       pgmatlab.loadPamguardMultiFile('./path/to/dir', fileNames, uids, 1);
%

eventData = [];
nEvents = 0;
if nargin < 4
    verbose = 0;
end

% find the files we need using the findBinaryFile function. 
% unique file list
unFiles = unique(fileNames);
for i = 1:numel(unFiles)
    if (verbose)
        fileName = unFiles{i};
        if length(dir) < length(fileName)
            fileName = fileName(length(dir):end);
        end
        fprintf('Loading file %s %d of %d\n', fileName, i, numel(unFiles));
    end
    
    filePath = pgmatlab.findBinaryFile(dir,'*.pgdf',unFiles{i});
    % Ensure the file exists
    if ~exist(filePath, 'file')
        fprintf(' - Unable to find file %s\n', unFiles{i});
        continue;
    end
    
    % list of clicks in a particular file
    mask = strcmp(fileNames, unFiles{i});
    fileUIDs = UIDs(mask);

    fileData = pgmatlab.loadPamguardBinaryFile(filePath, 'uidlist', fileUIDs);
    
    % Do some validation checks. Warn user if no (or not enough) data is found.
    if isempty(fileData)
        fprintf(' - No data found for file "%s" matching UIDs [%s]\n', unFiles{i}, sprintf('%d, ', fileUIDs));
        continue;
    end
    if length(fileData) ~= length(fileUIDs)
        fprintf(' - Only %d/%d data points found for file "%s" matching UIDs [%s]\n', length(fileData), length(fileUIDs), unFiles{i}, sprintf('%d, ', fileUIDs));
    end
    
    % Add the file information to all data loaded. 
    [~,fName,fEnd] = fileparts(filePath);
    fileName = [fName fEnd];
    for d = 1:numel(fileData)
        fileData(d).binaryFile = fileName;
    end

    % Preallocate eventData (performance)
    eventData = pgmatlab.utils.checkArrayAllocation(eventData, numel(eventData) + numel(fileData), fileData(1));
    nEvents = nEvents + numel(fileData);
    eventData(end-numel(fileData)+1:end) = fileData;
end
% Cut short preallocated eventData to the correct size
eventData = eventData(1:nEvents);
end