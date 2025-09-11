% StandardModuleHeader.m

classdef StandardModuleHeader < pgmatlab.core.standard.BaseChunk
    methods
        function obj = StandardModuleHeader(); end
        function data = readImpl(obj, fid, data, fileInfo, length, identifier); end
        function data = read(obj, fid, data, fileInfo, length, identifier) 
            data.length = length;
            data.identifier = identifier;
            data.version = fread(fid, 1, 'int32');
            data.binaryLength = fread(fid, 1, 'int32');
            data = obj.readImpl(fid, data, fileInfo, length, identifier);
        end
    end
end



