classdef WhistleAndMoan < pgmatlab.core.standard.StandardModule
    properties
        objectType = 2000;
    end
    methods
        function obj = WhistleAndMoan()
            obj.header = @pgmatlab.core.modules.detectors.WhistleAndMoanHeader;
            obj.background = @pgmatlab.core.modules.detectors.SpectralBackground;
        end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);
            if (fileInfo.moduleHeader.version<=1)
                data.startSample = fread(fid, 1, 'int64');
                data.channelMap = fread(fid, 1, 'int32');
            end
            
            data.nSlices = fread(fid, 1, 'int16');
            
            if (fileInfo.moduleHeader.version >= 1)
                data.amplitude = fread(fid, 1, 'int16') / 100;
            end
            
            if (fileInfo.moduleHeader.version == 1)
                data.nDelays = fread(fid, 1, 'int8');
                data.delays = fread(fid, data.nDelays, 'int16'); % need to scale this still !!!!
                if ~isempty(fileInfo.moduleHeader)
                    data.delays = data.delays / fileInfo.moduleHeader.delayScale;
                end
            end
            
            data.sliceData = [];
            data.contour = zeros(1,data.nSlices);
            data.contWidth = zeros(1,data.nSlices);
            for i = 1:data.nSlices
                aSlice.sliceNumber = fread(fid, 1, 'int32');
                aSlice.nPeaks = fread(fid, 1, 'int8');
                aSlice.peakData = zeros(4, aSlice.nPeaks);
                for p = 1:aSlice.nPeaks
                    sss = fread(fid, 4, 'int16');
                    aSlice.peakData(:,p) = sss;
                end
                data.sliceData{i} = aSlice;
                data.contour(i) = aSlice.peakData(2,1);
                data.contWidth(i) = aSlice.peakData(3,1) - aSlice.peakData(1,1) + 1;
            end
            data.meanWidth = mean(data.contWidth);
        end
    end
end