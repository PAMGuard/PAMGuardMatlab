classdef ClickFooter < pgmatlab.core.standard.StandardModuleFooter
    methods
        function obj = ClickFooter(); end
        function data = readImpl(obj, fid, data, fileInfo, length, identifier);
            if (data.binaryLength ~= 0)
                data.typesCountLength = fread(fid, 1, 'int16');
                data.typesCount = fread(fid, data.typesCountLength, 'int32');
            end
        end
    end
end