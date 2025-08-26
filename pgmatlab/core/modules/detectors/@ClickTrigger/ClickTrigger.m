classdef ClickTrigger < StandardModule
    properties
        objectType = 0;
    end
    methods
        function obj = ClickTrigger()
            obj.header = @ClickTriggerHeader;
        end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);

            nChan = countChannels(data.channelMap);
            scale = fread(fid, 1, 'float32');
            data.rawLevels = fread(fid, nChan, 'int16') / scale;
            cal = fileInfo.moduleHeader.calibration;
            if ~isempty(cal)
                data.absLevelsdB = 20*log10(data.rawLevels) + cal; 
            end
        end
    end
end