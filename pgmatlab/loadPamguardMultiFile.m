function eventData = loadPamguardMultiFile(dir, fileNames, UIDs, verbose)
%LOADPAMGUARDMULTIFILE - Load multiple <a href="https://www.pamguard.org/olhelp/utilities/BinaryStore/docs/binarystore_overview.html">PAMGuard Binary Files</a> into memory filtering by certain UIDs in certain files.
%
%   This is a depracated function for pgmatlab v1. To access the latest
%   code, use the function pgmatlab.loadPamguardMultiFile.
%
%   Syntax:
%       eventData = LOADPAMGUARDMULTIFILE(dir, fileNames, UIDs, verbose)
%   
%   See also PGMATLAB.LOADPAMGUARDMULTIFILE, PGMATLAB.LOADPAMGUARDBINARYFILE, PGMATLAB.LOADPAMGUARDBINARYFOLDER.

warning("loadPamguardMultiFile is deprecated. Use pgmatlab.loadPamguardMultiFile instead.");

% Handle optional arguments
if nargin < 4
    verbose = 0;
end

eventData = pgmatlab.loadPamguardMultiFile(dir, fileNames, UIDs, verbose);

end