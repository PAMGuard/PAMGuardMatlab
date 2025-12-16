classdef GibbonResult < pgmatlab.core.standard.StandardModule
    properties
        objectType = 0;
    end
    methods
        function obj = GibbonResult(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);

            data.nResult = fread(fid, 1, 'int16');
            data.results = fread(fid, data.nResult, 'float32')';
            % put the result times in too for convenience. 
            millisPerDay = 3600*24*1000;
            dOffs = [0:data.nResult-1]/data.nResult*data.millisDuration/millisPerDay;
            data.resultsDate = data.date + dOffs;

        end
    end
end