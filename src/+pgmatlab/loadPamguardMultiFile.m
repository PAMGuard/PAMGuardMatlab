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
%       fileNames = 
%

eventData = [];
if nargin < 4
    verbose = 0;
end

% find the files we need using the findBinaryFile function. 
% unique file list
unFiles = unique(fileNames);
for i = 1:numel(unFiles) % loop over the different files

    if (verbose)
        fileName = unFiles{i};
        if length(dir) < length(fileName)
            fileName = fileName(length(dir):end);
        end
        fprintf('Loading file %s %d of %d\n', fileName, i, numel(unFiles));
    end

    disp("Un files: " + unFiles{i})
    filePath = pgmatlab.findBinaryFile(dir,'*.pgdf',unFiles{i});
    disp("File path: " + unFiles{i});
    disp("I GOT HERE");
    disp(filePath);

    % list of clicks in a particular file
    fileUIDs = UIDs(find(strcmp(fileNames, unFiles{i})));

    fileData = pgmatlab.loadPamguardBinaryFile(filePath, 'uidlist', fileUIDs);
    % add the file information to all data loaded. 
    [~,fName,fEnd] = fileparts(filePath);
    fileName = [fName fEnd];
    for d = 1:numel(fileData)
        fileData(d).binaryFile = fileName;
    end

    eventData = [eventData fileData];
end

