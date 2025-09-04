function filePath = findBinaryFileForDate(root, mask, dates, verbose)
% find a file in the root that has data in the dates range. if necessary
% dates may be a vector and multiple files may be returned. 
if nargin < 4
    verbose = 0;
end
if numel(dates) > 1
    filePath = cell(size(dates));
    mt = zeros(size(dates));
    for i = 1:numel(dates)
        filePath{i} = pgmatlab.findBinaryFileForDate(root, mask, dates(i), verbose);
        mt(i) = isempty(filePath{i});
    end
    % remove nulls
    filePath = filePath(find(mt==0));

    return
end
% from here it's only a single date. 
% need to catalog all the times of all the pgdx files. 
persistent lastRoot lastMask;
persistent masterList namesOnly shortenedNames dataStarts dataEnds;
if needFullSearch(lastRoot, lastMask, root, mask)
    maxNameLen = 80; % problem in database limiting names to 80 characters
    if (verbose)
        fprintf('Searching folder %s for files type %s\n', root, mask);
    end
    masterList = pgmatlab.utils.dirsub(root, mask);
    namesOnly = cell(1,numel(masterList));
    shortenedNames = cell(1,numel(masterList));
    dataStarts = zeros(1,numel(masterList));
    dataEnds = zeros(1,numel(masterList));
    for i = 1:numel(masterList)
        if (verbose)
            if mod(i,100) == 0
                fprintf('Extracting times from file %d of %d: %s\n', ...
                    i, numel(masterList), masterList(i).name);
            end
        end
        xFile = strrep(masterList(i).name, '.pgdf', '.pgdx');
        [~, fileInfo] = pgmatlab.loadPamguardBinaryFile(xFile);
        try
            dataStarts(i) = fileInfo.fileHeader.dataDate;
            dataEnds(i) = fileInfo.fileFooter.dataDate;
        catch
            fprintf('Error in file %s\n', xFile);
        end
    end

    for i = 1:numel(masterList)
        fn = masterList(i).name;
        fp = masterList(i).folder;
       namesOnly{i} = fn(length(fp)+2:end);
       shortenedNames{i} = namesOnly{i};
       if length(shortenedNames{i}) > maxNameLen
           shortenedNames{i} = shortenedNames{i}(end-(maxNameLen-1):end);
       end
    end
    lastRoot = root;
    lastMask = mask;
end
filePath = [];
% find files in the right date range. 
wants = find(dates>=dataStarts & dates <=dataEnds);
if numel(wants)
    filePath = masterList(wants).name;
end

end
function full =needFullSearch(lastRoot, lastMask, root, mask)
if isempty(lastRoot) || isempty(lastMask)
    full = true;
    return;
end
full = ~(strcmp(lastRoot, root) && strcmp(lastMask, mask));
end