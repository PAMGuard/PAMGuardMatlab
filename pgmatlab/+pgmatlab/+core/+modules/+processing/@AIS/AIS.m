classdef AIS < pgmatlab.core.standard.StandardModule
    properties
        objectType = 0;
    end
    methods
        function obj = AIS(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);
            data.mmsiNumber = fread(fid, 1, 'int32');
            data.fillBits = fread(fid, 1, 'int16');
            [strVal, strLen] = pgmatlab.utils.readJavaUTFString(fid); %#ok<ASGLU>
            data.charData = strVal;
            [strVal, strLen] = pgmatlab.utils.readJavaUTFString(fid); %#ok<ASGLU>
            data.aisChannel = strVal;
        end
    end
end