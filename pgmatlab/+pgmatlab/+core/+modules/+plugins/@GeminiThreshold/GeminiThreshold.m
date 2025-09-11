

classdef GeminiThreshold < pgmatlab.core.standard.StandardModule
    properties
        objectType = 0;
    end
    methods
        function obj = GeminiThreshold();
            obj.background = @pgmatlab.core.modules.plugins.GeminiThresholdBackground;
        end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);

            data.nPoints = fread(fid, 1, 'int32');
            data.nSonar = fread(fid, 1, 'int8');
            data.sonarIds = fread(fid, data.nSonar, 'int16');
            dum = fread(fid,3,'float32');
            data.straightLength = dum(1);
            data.wobblyLength = dum(2);
            data.meanOccupancy = dum(3);
            data.timeMillis = zeros(1, data.nPoints);
            data.sonarId = zeros(1, data.nPoints);
            data.minBearing = zeros(1, data.nPoints);
            data.maxBearing = zeros(1, data.nPoints);
            data.peakBearing = zeros(1, data.nPoints);
            data.minRange = zeros(1, data.nPoints);
            data.maxRange = zeros(1, data.nPoints);
            data.peakRange = zeros(1, data.nPoints);
            data.objSize = zeros(1, data.nPoints);
            data.occupancy = zeros(1, data.nPoints);
            data.aveValue = zeros(1, data.nPoints);
            data.totValue = zeros(1, data.nPoints);
            data.maxValue = zeros(1, data.nPoints);
            for i = 1:data.nPoints
                data.timeMillis(i) = fread(fid, 1, 'int64');
                data.sonarId(i) = fread(fid, 1, 'int16');
                fDum = fread(fid,8,'float32');
                data.minBearing(i) = fDum(1);
                data.maxBearing(i) = fDum(2);
                data.peakBearing(i) = fDum(3);
                data.minRange(i) = fDum(4);
                data.maxRange(i) = fDum(5);
                data.peakRange(i) = fDum(6);
                data.objSize(i) = fDum(7);
                data.occupancy(i) = fDum(8);
                data.aveValue(i) = fread(fid, 1, 'int16');
                data.totValue(i) = fread(fid, 1, 'int32');
                data.maxValue(i) = fread(fid, 1, 'int16');
            end
            data.dates = pgmatlab.utils.millisToDateNum(data.timeMillis);
        end
    end
end