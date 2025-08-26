% StandarFileHeader.m

classdef StandardFileHeader < BaseChunk
    methods
        function obj = StandardFileHeader(); end
        function [data, selState] = read(obj, fid, data, fileInfo, length, identifier) 
            [data, selState] = read@BaseChunk(obj, fid, data, fileInfo, length, identifier);
            data.length = length;
            data.identifier = identifier;
            data.fileFormat = fread(fid, 1, 'int32');
            data.pamguard = char(fread(fid, 12, 'uchar')');
            data.version = readJavaUTFString(fid);
            data.branch = readJavaUTFString(fid);
            data.dataDate = millisToDateNum(fread(fid, 1, 'int64'));
            data.analysisDate = millisToDateNum(fread(fid, 1, 'int64'));
            data.startSample = fread(fid, 1, 'int64');
            data.moduleType = readJavaUTFString(fid);
            data.moduleName = readJavaUTFString(fid);
            data.streamName = readJavaUTFString(fid);
            data.extraInfoLen = fread(fid, 1, 'int32');
            % TODO: extra info is not always expected
            % data.extraInfo = [];
            if (data.extraInfoLen > 0)
                data.extraInfo = fread(fid, data.extraInfoLen, 'int8');
            end
        end
    end
end
