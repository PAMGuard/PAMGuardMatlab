classdef Difar < pgmatlab.core.standard.StandardModule
    properties
        objectType = 0;
    end
    methods
        function obj = Difar(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);

            if (fileInfo.moduleHeader.version <= 1)
                data.startSample = fread(fid, 1, 'int64');
            end

            data.clipStart = fread(fid, 1, 'int64');
            
            if (fileInfo.moduleHeader.version <= 1)
                data.channelMap = fread(fid, 1, 'int32');
            end
            
            data.displaySampleRate = fread(fid, 1, 'float');
            data.demuxedLength = fread(fid, 1, 'int32');
            
            if (fileInfo.moduleHeader.version <= 1)
                minFreq = fread(fid,1,'float');
                maxFreq = fread(fid,1,'float');
                data.freqLimits = [minFreq maxFreq];
            end
            
            data.amplitude = fread(fid, 1, 'float');
            data.gain = fread(fid, 1, 'float');
            data.selAngle = fread(fid, 1, 'float');
            data.selFreq = fread(fid, 1, 'float');
            data.speciesCode = pgmatlab.utils.readJavaUTFString(fid);

            if (fileInfo.moduleHeader.version >= 1)
                data.trackedGroup = pgmatlab.utils.readJavaUTFString(fid);
            end
            
            data.maxVal = fread(fid, 1, 'float');
            
            if (data.demuxedLength==0)
                data.demuxData = 0;
            else
                data.demuxData = fread(fid, [data.demuxedLength,3], 'int16') * data.maxVal / 32767;
            end
            
            data.numMatches = fread(fid, 1, 'int16');
            if (data.numMatches > 0)
                data.latitude = fread(fid, 1, 'float');
                data.longitude = fread(fid, 1, 'float');
                
                if (fileInfo.moduleHeader.version >= 1)
                    errorX = fread(fid,1,'float');
                    errorY = fread(fid,1,'float');
                    data.errors = [errorX errorY 0];
                end
                
                for i=1:data.numMatches-1
                    data.matchChan(i) = fread(fid, 1, 'int16');
                    data.matchTime(i) = fread(fid, 1, 'int64');
                end
            else
                data.latitude = 0;
                data.longitude = 0;
                
                if (fileInfo.moduleHeader.version >= 1)
                    data.errors = [0 0 0];
                end
                
                data.matchChan(1) = 0;
                data.matchTime(1) = 0;
            end
        end
    end
end