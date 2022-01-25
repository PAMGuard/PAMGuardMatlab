function [data, selState] = readPamData(fid, fileInfo, timeRange, uidRange)
% Reads in the object data that is common to all modules.  This reads up to
% (but not including) the object binary length, and then calls a function
% to read the module-specific data.
% Inputs:
%   fid = file identifier
%   fileInfo = structure holding the file header, module header, a handle
%   to the function to read module-specific data, etc.
%   timeRange two element array of Matlab datenum times
%   uidRange two element array of the uid range.
%
% Output:
%   data = structure containing data from a single object
% % % %   hasAnnotation = flag to say that data expect to have annotations
% % % %   following main data fields
%   selState = 0 if data are before minimum time or UID, 1 if within range
%   and 2 if after the range.



% set constants to match flag bitmap constants in class
% DataUnitBaseData.java.  The following contstants match header version 4.
% to speed this up use gloab variables

persistent   TIMEMILLIS
persistent   TIMENANOS
persistent   CHANNELMAP
persistent   UID
persistent   STARTSAMPLE
persistent   SAMPLEDURATION
persistent   FREQUENCYLIMITS
persistent   MILLISDURATION
persistent   TIMEDELAYSSECS
persistent   HASBINARYANNOTATIONS

if isempty(TIMEMILLIS)
    %only declarfe these once
    TIMEMILLIS           = hex2dec('1');
    TIMENANOS            = hex2dec('2');
    CHANNELMAP           = hex2dec('4');
    UID                  = hex2dec('8');
    STARTSAMPLE          = hex2dec('10');
    SAMPLEDURATION       = hex2dec('20');
    FREQUENCYLIMITS      = hex2dec('40');
    MILLISDURATION       = hex2dec('80');
    TIMEDELAYSSECS       = hex2dec('100');
    HASBINARYANNOTATIONS = hex2dec('200');
end
HASSEQUENCEMAP       = hex2dec('400');
HASNOISE             = hex2dec('800');
HASSIGNAL            = hex2dec('1000');
HASSIGNALEXCESS      = hex2dec('2000');

% initialize a new variable to hold the data
data=[];
data.flagBitmap=0;
hasAnnotation = 0;
selState = 1;

% calculate where the next object starts, in case there is an error trying
% to read this one
objectLen = fread(fid, 1, 'int32');
curObj = ftell(fid);
nextObj = curObj + objectLen;

% first thing to check is that this is really the type of object we think
% it should be, based on the file header.  If not, warn the user, move the
% pointer to the next object, and exit
data.identifier = fread(fid, 1, 'int32');
% this is a re-read of the type of object, so we can use this to check for
% a -6 which indicates background noise data which will need totally
% different treatment.
isBackground = data.identifier == -6;
% if isBackground
%     data.identifier
% end

if ~isBackground & isfield(fileInfo, 'objectType')
    if (any(data.identifier==fileInfo.objectType))
        % do nothing here - couldn't figure out a clean way of checking if
        % number wasn't in array
    else
        disp(['Error - Object Identifier does not match ' fileInfo.fileHeader.moduleType ' type.  Aborting data read.']);
        fseek(fid, nextObj, 'bof');
        return;
    end
end

% read the data, starting with the standard data that every data unit has
version=fileInfo.fileHeader.fileFormat;
try
    data.millis = fread(fid, 1, 'int64');
    
    if (version >=3)
        data.flagBitmap = fread(fid,1,'int16');
    end
    
    if (version == 2 || (bitand(data.flagBitmap, TIMENANOS)~=0) )
        data.timeNanos = fread(fid,1,'int64');
    end
    
    if (version == 2 || (bitand(data.flagBitmap, CHANNELMAP)~=0) )
        data.channelMap = fread(fid,1,'int32');
    end
    
    if (bitand(data.flagBitmap, UID)==UID)
        data.UID = fread(fid,1,'int64');
        if (data.UID < uidRange(1))
            selState = 0;
        elseif (data.UID > uidRange(2))
            selState = 2;
        end
    end
    
    if (bitand(data.flagBitmap, STARTSAMPLE)~=0)
        data.startSample = fread(fid,1,'int64');
    end
    
    if (bitand(data.flagBitmap, SAMPLEDURATION)~=0)
        data.sampleDuration = fread(fid,1,'int32');
    end
    
    if (bitand(data.flagBitmap, FREQUENCYLIMITS)~=0)
        minFreq = fread(fid,1,'float');
        maxFreq = fread(fid,1,'float');
        data.freqLimits = [minFreq maxFreq];
    end
    
    if (bitand(data.flagBitmap, MILLISDURATION)~=0)
        data.millisDuration = fread(fid,1,'float');
    end
    
    if (bitand(data.flagBitmap, TIMEDELAYSSECS)~=0)
        data.numTimeDelays = fread(fid,1,'int16');
        td=zeros(1, data.numTimeDelays);
        for i = 1:data.numTimeDelays
            td(i)=fread(fid,1,'float');
        end
        data.timeDelays=td;
    end
    
    if (bitand(data.flagBitmap, HASSEQUENCEMAP)~=0)
        data.sequenceMap = fread(fid,1,'int32');
    end
    if (bitand(data.flagBitmap, HASNOISE)~=0)
        data.noise = fread(fid,1,'float32');
    end
    if (bitand(data.flagBitmap, HASSIGNAL)~=0)
        data.signal = fread(fid,1,'float32');
    end
    if (bitand(data.flagBitmap, HASSIGNALEXCESS)~=0)
        data.signalExcess = fread(fid,1,'float32');
    end
    
    
    % set date, to maintain backwards compatibility
    data.date = millisToDateNum(data.millis);
    %     disp(['Check date' num2str(data.date) ' for ' num2str(timeRange(1))...
    %         ' to ' num2str(timeRange(2))])
    if (data.date < timeRange(1))
        selState = 0;
    elseif (data.date > timeRange(2))
        selState = 2;
    end
    
    % now read the module-specific data
    if isBackground
        if(isa(fileInfo.readModuleData,'function_handle'))
            [data, error] = fileInfo.readBackgroundData(fid, fileInfo, data);
            if (error)
                disp(['Error - cannot retrieve ' fileInfo.fileHeader.moduleType ' data properly.']);
                fseek(fid, nextObj, 'bof');
                return;
            end
        end
    else
        if(isa(fileInfo.readModuleData,'function_handle'))
            [data, error] = fileInfo.readModuleData(fid, fileInfo, data);
            if (error)
                disp(['Error - cannot retrieve ' fileInfo.fileHeader.moduleType ' data properly.']);
                fseek(fid, nextObj, 'bof');
                return;
            end
        end
    end
    % now check to see if there are standard annotations to the main data.
    if (bitand(data.flagBitmap, HASBINARYANNOTATIONS)~=0)
        
        hasAnnotation = 1;
        anStart = ftell(fid);
        anTotLength = fread(fid, 1, 'int16');
        nAn = fread(fid, 1, 'int16');
        
        %         disp(['Number annotation: ' num2str(nAn)  ' ' num2str(anTotLength) ])
        for i = 1:nAn
            filePos = ftell(fid);
            anLength = fread(fid, 1, 'int16')-2; %tis length does no tinclude itself !
            anId = readJavaUTFString(fid);
            anVersion = fread(fid, 1, 'int16');
            switch (anId)
                case 'Beer'
                    data.annotations.beamAngles = readBeamFormerAnnotation(fid, anId, anLength, fileInfo, anVersion);
                case 'Bearing'
                    data.annotations.bearing = readBearingAnnotation(fid, anId, anLength, fileInfo, anVersion);
                case 'TMAN'
                    data.annotations.targetMotion = readTMAnnotation(fid, anId, anLength, fileInfo, anVersion);
                case 'TDBL'
                    data.annotations.toadAngles = readTDBLAnnotation(fid, anId, anLength, fileInfo, anVersion);
                case 'ClickClasssifier_1'
                    data.annotations.classification = readClickClsfrAnotation(fid, anId, anLength, fileInfo, anVersion);
                case 'Matched_Clk_Clsfr'
                    data.annotations.mclassification = readMatchClsfrAnnotation(fid, anId, anLength, fileInfo, anVersion);
                case 'BCLS' %Basic classificatio
                    data.annotations.basicclassification = readRWUDPAnnotation(fid, anId, anLength, fileInfo, anVersion);
                case {'DLRE', 'Delt'}
                    data.annotations.dlclassification = readDLAnnotation(fid, anId, anLength, fileInfo, anVersion);
                otherwise
                    fprintf('Unknown anotation type "%s" length %d version %d in file\n', ...
                        anId, anLength, anVersion);
                    fseek(fid, filePos+anLength, 'bof');
            end
            endPos = ftell(fid);
            if (endPos ~= filePos+anLength)
                disp('Possible annotation read size error in file')
                fseek(fid, filePos+anLength, 'bof');
                endPos = ftell(fid);
            end
        end
        if (endPos ~= anStart+anTotLength)
            fseek(fid, anStart+anTotLength, 'bof');
        end
    else
        data.annotations = [];
    end
    
catch mError
    disp('Error loading object data');
    disp(data);
    disp(getReport(mError));
    fseek(fid, nextObj, 'bof');
end
end
