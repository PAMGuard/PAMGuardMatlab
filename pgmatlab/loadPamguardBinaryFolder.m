function [allData, allBackground, fileInfos] = loadPamguardBinaryFolder(dir, fileMask, verbose, filterfun)
%LOADPAMGUARDBINARYFOLDER - Load many <a href="https://www.pamguard.org/olhelp/utilities/BinaryStore/docs/binarystore_overview.html">PAMGuard Binary Files</a> into memory from a folder (and subfolders).
%
%   This is a depracated function for pgmatlab v1. To access the latest
%   code, use the function pgmatlab.loadPamguardBinaryFolder. Read full
%   documentation, as the function signature has changed.
%
%   Syntax:
%       [allData, allBackground, fileInfos] = LOADPAMGUARDBINARYFOLDER(dir, fileMask, verbose, filterfun)
%       [allData, allBackground] = LOADPAMGUARDBINARYFOLDER(dir, fileMask, verbose, filterfun)
%       allData = LOADPAMGUARDBINARYFOLDER(dir, fileMask, verbose, filterfun)
%   
%   See also PGMATLAB.LOADPAMGUARDBINARYFOLDER, PGMATLAB.LOADPAMGUARDBINARYFILE, PGMATLAB.LOADPAMGUARDMULTIFILE.

% Handle optional arguments
if nargin < 3
    verbose = 0;
end

if nargin < 4
    filterfun = 0;
end

warning("loadPamguardBinaryFolder is deprecated. Use pgmatlab.loadPamguardBinaryFolder instead. Read full documentation, as the function signature has changed.");

if isa(filterfun, "function_handle")
    [allData, allBackground, fileInfos] = pgmatlab.loadPamguardBinaryFolder(dir, fileMask, verbose, 'filter', filterfun);
else
    [allData, allBackground, fileInfos] = pgmatlab.loadPamguardBinaryFolder(dir, fileMask, verbose);
end
end