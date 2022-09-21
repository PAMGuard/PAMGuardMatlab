function eventData = loadPamguardMultiFile(dataDir, fileNames, itemUID)
% function to load all data from an event even if spread over multiple
% files. This can be used to get binary file data for data associated with
% PAMGuard 'events' marked out using the click detector or the 'Detection
% Grouper'. From the database query, for each event make a list of the
% fileNames and the UID's of individual datas, then this function will call
% loadPamguardBinaryFile(...) for each of one or more files associated with
% the event and merge all the data into one array of structure. 
%
% inputs are root data folder, cell array of binary file names and click
% numbers
%
% eventData = loadPamguardMultiFile(dataDir, fileNames, itemUID)
%   'dataDir': root folder for binary data
%   'fileNames': list of file names for each item of interest (generally read from database)
%   'itemUID': list of UID's of wanted data. Shoule be same length as array of file names
%
% returns binary data from multiple files. 

eventData = [];

% find the files we need using the findBinaryFile function. 
% unique file list
unFiles = unique(fileNames);
for i = 1:numel(unFiles) % loop over the different files

    filePath = findBinaryFile(dataDir,'*.pgdf',unFiles{i});

    % list of clicks in a particular file
    fileUIDs = itemUID(find(strcmp(fileNames, unFiles{i})));

    fileData = loadPamguardBinaryFile(filePath, 'uidlist', fileUIDs);
    eventData = [eventData fileData];
end

