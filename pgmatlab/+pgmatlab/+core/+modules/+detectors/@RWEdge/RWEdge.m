classdef RWEdge < pgmatlab.core.standard.StandardModule
    properties
        objectType = 0;
    end
    methods
        function obj = RWEdge(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);

            isBuoy = (fileInfo.fileHeader.fileFormat == 0);
            if (fileInfo.moduleHeader.version== 0 || isBuoy)
                data.startSample = fread(fid, 1, 'int64');
                data.channelMap = fread(fid, 1, 'int32');
            end
            
            data.type = fread(fid, 1, 'int16');
            data.signal = fread(fid, 1, 'float');
            data.noise = fread(fid, 1, 'float');
            data.nSlices = fread(fid, 1, 'int16');
            
            data.times = zeros(1, data.nSlices);
            data.sliceNums = zeros(1, data.nSlices);
            data.loFreqs = zeros(1, data.nSlices);
            data.peakFreqs = zeros(1, data.nSlices);
            data.hiFreqs = zeros(1, data.nSlices);
            data.peakAmps = zeros(1, data.nSlices);
            for i = 1:data.nSlices
                data.sliceNums(i) = fread(fid, 1, 'int16');
                data.loFreqs(i) = fread(fid, 1, 'int16');
                data.peakFreqs(i) = fread(fid, 1, 'int16');
                data.hiFreqs(i) = fread(fid, 1, 'int16');
                data.peakAmps(i) = fread(fid, 1, 'float');
            end   
        end
    end
end