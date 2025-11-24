classdef IshmaelData < pgmatlab.core.standard.StandardModule
    properties
        objectType = [];
    end
    methods
        function obj = IshmaelData(); end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);

            nDet = fread(fid, 1, 'int32');
            nDet2 = 2;
            if fileInfo.moduleHeader.version >= 2
                nDet2 = fread(fid, 1, 'int32');
            end
            data.data = zeros(nDet,nDet2);
            for i = 1:nDet
                for i2 = 1:nDet2
                    data.data(i,i2) = fread(fid, 1, 'double');
                end
            end
        end
    end
end