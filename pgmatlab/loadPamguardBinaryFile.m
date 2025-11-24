function [data, fileInfo, selState] = loadPamguardBinaryFile(filename, varargin)
%LOADPAMGUARDBINARYFILE - Load a <a href="https://www.pamguard.org/olhelp/utilities/BinaryStore/docs/binarystore_overview.html">PAMGuard Binary File</a> into memory.
%
%   This is a depracated function for pgmatlab v1. To access the latest
%   code, use the function pgmatlab.loadPamguardBinaryFile.
%
%   Syntax:
%       [data, fileInfo, selState] = LOADPAMGUARDBINARYFILE(filename, varargin)
%       [data, fileInfo] = LOADPAMGUARDBINARYFILE(filename, varargin)
%       data = LOADPAMGUARDBINARYFILE(filename, varargin)
%   
%   See also PGMATLAB.LOADPAMGUARDBINARYFILE, LOADPAMGUARDBINARYFOLDER, LOADPAMGUARDMULTIFILE.

warning("loadPamguardBinaryFile is deprecated. Use pgmatlab.loadPamguardBinaryFile instead.");
[data, fileInfo, selState] = pgmatlab.loadPamguardBinaryFile(filename, varargin{:});

end