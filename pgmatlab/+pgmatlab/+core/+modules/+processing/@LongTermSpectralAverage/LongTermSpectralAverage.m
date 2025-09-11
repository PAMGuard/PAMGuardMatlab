classdef LongTermSpectralAverage < pgmatlab.core.standard.StandardModule
    properties(Access = private)
        a = 127.*2./log(32767);
        b = -127;
    end
    properties
        objectType = 1;
    end
    methods
        function obj = LongTermSpectralAverage();
            obj.header = @pgmatlab.core.modules.processing.LongTermSpectralAverageHeader;
        end
        function [data, selState] = readImpl(obj, fid, data, fileInfo, length, identifier, selState);
            
            if (fileInfo.moduleHeader.version<=1)
                data.startSample = fread(fid, 1, 'int64');
            end

            if (fileInfo.moduleHeader.version==0)
                data.duration = fread(fid, 1, 'int64');
            end
            
            if (fileInfo.moduleHeader.version<=1)
                data.channelMap = fread(fid, 1, 'int32');
            end
            
            data.endMillis = fread(fid, 1, 'int64');
            data.endDate = pgmatlab.utils.millisToDateNum(data.endMillis);
            data.nFFT = fread(fid, 1, 'int32');
            data.maxVal = fread(fid, 1, 'float');
            
            % version 0 scaled the data linearly to 16 bit
            if (fileInfo.moduleHeader.version==0)    
                data.byteData = fread(fid, fileInfo.moduleHeader.fftLength/2, 'int16');
                data.data = data.byteData / 32767. * data.maxVal;
                
            % after version 0, the data was first scaled to 16 bit and then
            % converted to a log so that it could be saved as an 8 bit.
            else
                data.byteData = fread(fid, fileInfo.moduleHeader.fftLength/2, 'int8');
                data.data = exp((data.byteData-obj.b)/obj.a)*data.maxVal / 32767;
            end
        end
    end
end