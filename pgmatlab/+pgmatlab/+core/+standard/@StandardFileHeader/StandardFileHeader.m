% StandarFileHeader.m

classdef StandardFileHeader < pgmatlab.core.standard.BaseChunk
    methods
        function obj = StandardFileHeader(); end
        function [data, selState] = read(obj, fid, data, fileInfo, length, identifier) 
            [data, selState] = read@pgmatlab.core.standard.BaseChunk(obj, fid, data, fileInfo, length, identifier);
            data.length = length;
            data.identifier = identifier;
            data.fileFormat = fread(fid, 1, 'int32');
            data.pamguard = char(fread(fid, 12, 'uchar')');
            data.version = pgmatlab.utils.readJavaUTFString(fid);
            data.branch = pgmatlab.utils.readJavaUTFString(fid);
            data.dataDate = pgmatlab.utils.millisToDateNum(fread(fid, 1, 'int64'));
            data.analysisDate = pgmatlab.utils.millisToDateNum(fread(fid, 1, 'int64'));
            data.startSample = fread(fid, 1, 'int64');
            data.moduleType = pgmatlab.utils.readJavaUTFString(fid);
            data.moduleName = pgmatlab.utils.readJavaUTFString(fid);
            data.streamName = pgmatlab.utils.readJavaUTFString(fid);
            data.extraInfoLen = fread(fid, 1, 'int32');
            % TODO: extra info is not always expected
            % data.extraInfo = [];
            if (data.extraInfoLen > 0)
                data.extraInfo = fread(fid, data.extraInfoLen, 'int8');
            end
        end
    end
end
