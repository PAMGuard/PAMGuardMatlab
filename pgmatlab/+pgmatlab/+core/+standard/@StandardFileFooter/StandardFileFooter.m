% StandarFileFooter.m

classdef StandardFileFooter < pgmatlab.core.standard.BaseChunk
    methods
        function obj = StandardFileFooter(); end
        function [data, selState] = read(obj, fid, data, fileInfo, length, identifier) 
            import pgmatlab.*;
            [data, selState] = read@pgmatlab.core.standard.BaseChunk(obj, fid, data, fileInfo, length, identifier);
            version = fileInfo.fileHeader.version;
            data.length = length;
            data.identifier = identifier;
            data.nObjects = fread(fid, 1, 'int32');
            data.dataDate = pgmatlab.utils.millisToDateNum(fread(fid, 1, 'int64'));
            data.analysisDate = pgmatlab.utils.millisToDateNum(fread(fid, 1, 'int64'));
            data.endSample = fread(fid, 1, 'int64');
            if (version>=3)
                data.lowestUID = fread(fid, 1, 'int64');
                data.highestUID = fread(fid, 1, 'int64');
            end
            data.fileLength = fread(fid, 1, 'int64');
            data.endReason = fread(fid, 1, 'int32');
        end
    end
end
