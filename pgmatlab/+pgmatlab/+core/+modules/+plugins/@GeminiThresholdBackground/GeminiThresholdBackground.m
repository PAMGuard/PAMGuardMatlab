

classdef GeminiThresholdBackground < pgmatlab.core.standard.StandardBackground
    methods (Static)
        function glf = readTritechGLFRecord(fid, fileInfo) %#ok<*INUSD>
            endy = 'ieee-le';

            glf.id1 = fread(fid, 1, 'uint16', endy);
            glf.efef = dec2hex(fread(fid, 1, 'uint16', endy));
            glf.imageVersion = fread(fid, 1, 'uint16', endy);
            glf.startRange = fread(fid, 1, 'uint32', endy);
            glf.endRange = fread(fid, 1, 'uint32', endy);
            glf.rangeCompression = fread(fid, 1, 'uint16', endy);
            glf.startBearing = fread(fid, 1, 'uint32', endy);
            glf.endBearing = fread(fid, 1, 'uint32', endy);
            if (glf.imageVersion == 3)
                skip = fread(fid, 1, 'uint16', endy); %#ok<*NASGU>
            end
            % disp("I GOT HERE 1");
            nBearing = glf.endBearing-glf.startBearing;
            nRange = glf.endRange-glf.startRange;
            packedSize = fread(fid, 1, 'uint32', endy);
            zipped = uint8(fread(fid, packedSize, 'uint8', endy))';
            fullLen = nRange*nBearing;
            % disp(glf.imageVersion);
            try
                % from https://uk.mathworks.com/matlabcentral/answers/313672-java-class-inflater-call-from-matlab-command-window
                output      = java.io.ByteArrayOutputStream();
                unzipper = java.util.zip.Inflater;
                outstrm     = java.util.zip.InflaterOutputStream(output,unzipper);
                outstrm.write(zipped);
                unzipper.finished;
                outstrm.flush
                outstrm.close();
                % output to ByteArray
                unzipped = output.toByteArray();
            catch errr
                error = true;
                return;
            end

            % it seems that I wasn't flushing properly when writing the zipped data, so
            % the records are short and we're getting fewer measures back than
            % intended. Need to modify range data accordingly or it's all gonna go a
            % bit weird.
            if (length(unzipped) < fullLen)
                % fprintf('expLen %d, gotLen %d, inputlen %d, ratio %3.4f\n', fullLen, length(unzipped),packedSize, length(unzipped)/fullLen);
                nRange = floor(length(unzipped)/nBearing);
                glf.endRange = nRange;
                unzipped = unzipped(1:(nRange*nBearing));
            end

            % then reshape it before adding to the glf record
            % and deal with negatives ! 
            shortData = int16(unzipped);
            isNeg = find(shortData < 0);
            shortData(isNeg) = shortData(isNeg)+256;
            glf.imageData = reshape(shortData, nBearing, nRange);

            % now continue and get the rest of the stuff out of the record. 
            glf.bearingTable = fread(fid, nBearing, 'double', endy);
            glf.stateFlags = fread(fid, 1, 'uint32', endy);
            glf.modulationFrequency = fread(fid, 1, 'uint32', endy);
            glf.beamformAperture = fread(fid, 1, 'float32', endy);
            glf.txTime = fread(fid, 1, 'double', endy);
            glf.pingFlags = fread(fid, 1, 'uint16', endy);
            glf.sosAtXd = fread(fid, 1, 'float32', endy);
            glf.percentGain = fread(fid, 1, 'uint16', endy);
            glf.chirp = fread(fid, 1, 'uint8', endy);
            glf.sonarType = fread(fid, 1, 'uint8', endy);
            glf.platform = fread(fid, 1, 'uint8', endy);
            glf.oneSpare = fread(fid, 1, 'uint8', endy);
            glf.dede = dec2hex(fread(fid, 1, 'uint16', endy));

            glf.maxRange = glf.endRange * glf.sosAtXd/2. / glf.modulationFrequency;


            % finally, need to convert the times, which are some funny double number,
            % into something sensible such as millis or Matlab datenum. 
            % cDate is ref's to 1980 in secs, Matlab is days since '00-Jan-0000'
            tOffs = 723181; % datenum(1980,0,1,0,0,0)
            secsPerDay = 3600*24;
            glf.txDate = (glf.txTime / secsPerDay) + tOffs;
        end
        function head = readTritechHeader(fid, fileInfo)
            endy = 'ieee-le';
            head.m_idChar = fread(fid, 1, 'uint8', endy);
            head.m_version = fread(fid, 1, 'uint8', endy);
            head.m_length = fread(fid, 1, 'uint32', endy);
            head.m_timestamp = fread(fid, 1, 'double', endy);
            head.m_dataType = fread(fid, 1, 'uint8', endy);
            head.tm_deviceId = fread(fid, 1, 'uint16', endy);
            head.m_node_ID = fread(fid, 1, 'uint16', endy);
            head.spare = fread(fid, 1, 'uint16');
        end
    end
    
    methods
        function obj = GeminiThresholdBackground(); end        
        function [data, selState] = readImpl(~, fid, data, fileInfo, length, identifier, selState);
            data.head = pgmatlab.core.modules.plugins.GeminiThresholdBackground.readTritechHeader(fid, fileInfo);
            data.glf = pgmatlab.core.modules.plugins.GeminiThresholdBackground.readTritechGLFRecord(fid, fileInfo);
        end
    end
end