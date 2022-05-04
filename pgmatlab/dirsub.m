function files = dirsub(rootFolder, mask)
% function files = dirsub(rootFolder, mask)
% lists all files in the top level folder and all sub folders thereof. 
files = [];
if nargin < 1
    rootFolder = '.';
end
if nargin < 2
    mask = '*.*';
end
files = searchFolder(rootFolder, mask);
end

function files = searchFolder(aFolder, mask)
  % first do the fiels in this folder which match the mask.
  % check there is no / or \ on the end of afolder
%  disp(['Search folder ' aFolder]);
  files = [];
  lastChar = aFolder(end);
  if strcmp(lastChar, '/') || strcmp(lastChar, '\')
      aFolder = aFolder([1:end-1]);
  end
  files = dir([aFolder '/' mask]);
  for i = 1:length(files)
      files(i).name = fullfile(aFolder, files(i).name);
  end
  
  % now check out sub folders
  all = dir(aFolder);
  for i = 1:length(all)
      aFile = fullfile(aFolder, all(i).name);
      if ~isfolder(aFile)
          continue;
      end
      if strcmp(all(i).name(1),'.')
          continue;
      end
      moreFiles = searchFolder(aFile, mask);
      for f = 1:length(moreFiles)
          files(end+1) = moreFiles(f);
      end
  end
end
