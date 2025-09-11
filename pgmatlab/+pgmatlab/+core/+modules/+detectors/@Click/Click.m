classdef Click < pgmatlab.core.standard.StandardModule
    properties
        objectType = 1000;
    end
    methods
        function obj = Click(); 
            obj.footer = @pgmatlab.core.modules.detectors.ClickFooter;
            obj.background = @pgmatlab.core.modules.detectors.ClickBackground;
        end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);
            if (fileInfo.moduleHeader.version<=3)
                data.startSample = fread(fid, 1, 'int64');
                data.channelMap = fread(fid, 1, 'int32');
            end
            
            data.triggerMap = fread(fid, 1, 'int32');
            data.type = fread(fid, 1, 'int16');
            if (fileInfo.moduleHeader.version >= 2)
                data.flags = fread(fid, 1, 'int32');
            else
                data.flags = 0;
            end
            
            if (fileInfo.moduleHeader.version <= 3)
                nDelays = fread(fid, 1, 'int16');
                if (nDelays)
                    data.delays = fread(fid, nDelays, 'float');
                else 
                    data.delays=[]; 
                end
            end

            nAngles = fread(fid, 1, 'int16');
            if (nAngles)
                data.angles = fread(fid, nAngles, 'float');
            else
                data.angles = []; 
            end

            
            if (fileInfo.moduleHeader.version >= 3)
                nAngleErrors = fread(fid, 1, 'int16');
                data.angleErrors = fread(fid, nAngleErrors, 'float');
            else
                data.angleErrors = [];
            end
            
            if (fileInfo.moduleHeader.version <= 3)    
                data.duration = fread(fid, 1, 'uint16');
            else
                data.duration = data.sampleDuration;    % duplicate the value to maintain backwards compatibility
            end
            
            data.nChan = pgmatlab.utils.countChannels(data.channelMap);
            maxVal = fread(fid, 1, 'float');
            data.wave = fread(fid, [data.duration,data.nChan], 'int8') * maxVal / 127;    
        end
    end
end