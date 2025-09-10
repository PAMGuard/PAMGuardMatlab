function filePath = findBinaryFile(root, mask, file)
% find a file in the root, and mask with a given name. 
% will make a master list once, then reuse it to find the
% right file. 
persistent lastRoot lastMask;
persistent masterList namesOnly shortenedNames;
if needFullSearch(lastRoot, lastMask, root, mask)
    maxNameLen = 80; % problem in database limiting names to 80 characters
    masterList = pgmatlab.utils.dirsub(root, mask);
    disp(masterList(1));
    namesOnly = cell(1,numel(masterList));
    shortenedNames = cell(1,numel(masterList));

    for i = 1:numel(masterList)
        disp("I GOT HERE 1");
        fn = masterList(i).name;
        fp = masterList(i).folder;
        disp(fn)
        disp(fp);
        disp(length(fn));
       namesOnly{i} = fn(length(fp)+2:end);
       disp("Set names only: " + fn(length(fp)+2:end))
       shortenedNames{i} = namesOnly{i};
       if length(shortenedNames{i}) > maxNameLen
           shortenedNames{i} = shortenedNames{i}(end-(maxNameLen-1):end);
       end
    end
    lastRoot = root;
    lastMask = mask;
end
filePath = [];
disp(namesOnly(1));
wants = find(strcmp(namesOnly, file));
if (numel(wants) == 0)
    wants = find(strcmp(shortenedNames, file));
end
if numel(wants) ~= 1
    return
else
    disp(masterList)
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