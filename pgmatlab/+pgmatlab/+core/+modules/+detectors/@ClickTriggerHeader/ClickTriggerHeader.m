classdef ClickTriggerHeader < pgmatlab.core.standard.StandardModuleHeader
    methods
        function obj = ClickTriggerHeader(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier);
            if (data.binaryLength~=0)
                data.channelMap = fread(fid, 1, 'int32');
                nChan = pgmatlab.utils.countChannels(data.channelMap);
                data.calibration = fread(fid, nChan, 'float32');
            else 
                data.calibration = [];
            end
        end
    end
end