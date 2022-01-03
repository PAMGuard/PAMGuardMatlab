function filePath = findBinaryFile(root, mask, file)
% find a file in the root, and mask with a given name. 
% will make a master list once, then reuse it to find the
% right file. 
persistent lastRoot lastMask;
persistent masterList namesOnly;
if needFullSearch(lastRoot, lastMask, root, mask)
    masterList = dirsub(root, mask);
    namesOnly = cell(1,numel(masterList));
    for i = 1:numel(masterList)
        fn = masterList(i).name;
        fp = masterList(i).folder;
       namesOnly{i} = fn(length(fp)+2:end);
    end
    lastRoot = root;
    lastMask = mask;
end
filePath = [];
wants = find(strcmp(namesOnly, file));
if numel(wants) ~= 1
    return
else
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