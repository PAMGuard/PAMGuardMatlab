classdef SpermWhaleIPI < pgmatlab.core.standard.StandardModule
    properties
        objectType = 0;
    end
    methods
        function obj = SpermWhaleIPI();
            obj.background = @SpermWhaleIPIBackground;
        end
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);

            data.parentUID = fread(fid, 1, 'int64');            % 8
            data.ipi = fread(fid,1,'float');                    % 4
            data.ipiAmplitude = fread(fid,1,'float');           % 4
            data.sampleRate = fread(fid,1,'float');             % 4
            data.maxVal = fread(fid,1,'float');                 % 4
            data.echoLen = fread(fid, 1, 'int32');              % 4
            data.echoData = fread(fid, data.echoLen, 'int16')...
                                * data.maxVal / 32767;          % len * 2 
        end
    end
end