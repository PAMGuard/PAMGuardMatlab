classdef ClipGenerator < pgmatlab.core.standard.StandardModule
    properties
        objectType = [1 2];
    end
    methods
        function obj = ClipGenerator(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);

            if (fileInfo.moduleHeader.version <= 1)
                data.startSample = fread(fid, 1, 'int64');
                data.channelMap = fread(fid, 1, 'int32');
            end
            
            data.triggerMillis = fread(fid, 1, 'int64');
            
            if (fileInfo.moduleHeader.version <= 1)
                data.sampleDuration = fread(fid, 1, 'int32');
            end
            
            data.filename = pgmatlab.utils.readJavaUTFString(fid);
            data.triggerName = pgmatlab.utils.readJavaUTFString(fid);
            if (fileInfo.moduleHeader.version >= 3)
                data.triggerUID = fread(fid, 1, 'int64');
            end
            
            % check if the object type = 2.  If it is, there must be wav data at
            % the end of this object
            if (data.identifier==2)
                data.nChan = fread(fid, 1, 'int16');
                data.nSamps = fread(fid, 1, 'int32');
                data.scale = 1/fread(fid, 1, 'float');
            data.wave = fread(fid, [data.nSamps,data.nChan], 'int8') * data.scale;
            end
        end
    end
end