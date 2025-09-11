% StandardModuleFooter.m

classdef StandardModuleFooter < pgmatlab.core.standard.BaseChunk
    methods
        function obj = StandardModuleFooter(); end
        function data = readImpl(obj, fid, data, fileInfo, length, identifier); end
        function data = read(obj, fid, data, fileInfo, length, identifier) 
            import pgmatlab.*;
            data.length = length;
            data.identifier = identifier;
            data.binaryLength = fread(fid, 1, 'int32');
            data = obj.readImpl(fid, data, fileInfo, data.binaryLength, identifier);
        end
    end
end



