function [dataSet, fileInfo] = loadPamguardBinaryFile(fileName, varargin)
% Program to load a Pamguard binary file
% [dataSet, fileInfo] = loadPamguardBinaryFile(fileName, varargin)
% flleName is the full path to a PAMGuard pgdf file.
% varargin can be a number of paired parameters.
% 'timerange' must be followed by a two element data rage
% 'uidrange' must be followed by a two element UID range
%
% clicks =
% loadPamguardBinaryFile('C:/MyData/Click_Detector_Click_Detector_Clicks_20171021_002421.pgdf')
% will load all data from the data file
% Click_Detector_Click_Detector_Clicks_20171021_002421.pgdf into a Matlab
% structure.
%
% startdate = datenum(2017,10,21,0,25,0)
% enddate = datenum(2017,10,21,0,26,0)
% clicks =
% loadPamguardBinaryFile('C:/MyData/Click_Detector_Click_Detector_Clicks_20171021_002421.pgdf', 'timerange', [startdate enddate])
% will load clicks between 00:25 and 00:26 on 21 October 2017.
%
% clicks =
% loadPamguardBinaryFile('C:/MyData/Click_Detector_Click_Detector_Clicks_20171021_002421.pgdf',
% 'uidrange', [1000345 1000345]) will load a single click with UID 1000345
% into memory.
%
% clicks =
% loadPamguardBinaryFile('C:/MyData/Click_Detector_Click_Detector_Clicks_20171021_002421.pgdf',
% 'uidlist', [1000345 1000347 ...]) will load a list of specific UID's into
% memory.
%
% [dataSet, fileInfo] = loadPamguardBinaryFile( ... )
% will return an optional fileInfo structure containing header and footer
% information from the file which includes information such as the data
% start and end times.

% required for all chunks to work together
% addpath(genpath('./pgmatlab/chunks/'))
% addpath(genpath('./pgmatlab/utils/'))

dataSet = [];
fileInfo = [];
nBackground = 0;
timeRange = [-Inf +Inf];
uidRange = [-Inf +Inf];
uidList = [];
iArg = 0;
filterfun = @passalldata;
channelmap=-1;
while iArg < numel(varargin)
    iArg = iArg + 1;
    switch(varargin{iArg})
        case 'timerange'
            iArg = iArg + 1;
            %            timeRange = dateNumToMillis(varargin{iArg});
            timeRange = varargin{iArg};
        case 'uidrange'
            iArg = iArg + 1;
            uidRange = varargin{iArg};
        case 'uidlist'
            iArg = iArg + 1;
            uidList = sort(varargin{iArg});
        case 'filter'
            iArg = iArg + 1;
            filterfun = varargin{iArg};
        case 'channel'
            iArg = iArg + 1;
            channelmap = varargin{iArg};
    end
end
selState = 0;
% open binary file and read data
nData = 0;
try
    fid = fopen(fileName, 'r', 'ieee-be.l64');

    % initialize variables
    prevPos = -1;
    background = [];

    persistent backgroundObj;
    persistent moduleObj;


    % main loop
    while (1)

        % if for some reason we're stuck at one byte, warn the user and
        % abort
        pos = ftell(fid);
        if (pos == prevPos)
            disp(fprintf('File stuck at byte %d', pos));
            break;
        end
        prevPos = pos;

        % read in the length of the object and the type.
        [length, nL] = fread(fid, 1, 'int32');
        [identifier, nT] = fread(fid, 1, 'int32');
        if (nL == 0 || nT == 0), break; end
        nextPos = ftell(fid) - 8 + length;
        switch identifier

            % Case 1: File Header.  Read in the file header, and then set
            % the function handles depending on what type of data the
            % binary file holds.  The module type is typically specified in
            % the package class that extends PamControlledUnit, and is a
            % string unique to that module.
            case -1
                fileInfo.fileHeader = StandardFileHeader().read(fid, [], fileInfo, length, identifier);

                switch fileInfo.fileHeader.moduleType

                    % AIS Processing Module
                    case 'AIS Processing'
                        moduleObj = AIS();
                    
                    % Clip Generator Module
                    case 'Clip Generator'
                        moduleObj = ClipGenerator();

                    % DbHt Module
                    case 'DbHt'
                        moduleObj = DbHt();

                    % % Difar Module
                    case 'DIFAR Processing'
                        moduleObj = Difar();

                    % Ishmael Data & Detections
                    case {'Energy Sum Detector','Spectrogram Correlation Detector','Matched Filter Detector'}
                        switch fileInfo.fileHeader.streamName
                            case 'Ishmael Peak Data'
                                moduleObj = IshmaelData();
                                % TODO: specify objectType
                            case 'Ishmael Detections'
                                moduleObj = IshmaelDetections();
                                % TODO: specify objectType
                        end

                    % LTSA Module
                    case 'LTSA'
                        moduleObj = LongTermSpectralAverage();

                    % Filtered Noise Measurement Module (Noise One Band)
                    case 'NoiseBand'
                        moduleObj = NoiseBand();
                    
                    % Noise Monitor Module and Noise Band Monitor Module
                    % Note: The two modules have different types, but both
                    % use noiseMonitor.NoiseBinaryDataSource class to save
                    % data
                    case {'Noise Monitor', 'Noise Band'}
                        moduleObj = NoiseMonitor();

                    % Deep learning module
                    case 'Deep Learning Classifier'
                         switch fileInfo.fileHeader.streamName
                            case {'DL_detection', 'DL detection'}
                                moduleObj = DeepLearningClassifierDetections();
                            case {'DL_Model_Data', 'DL Model Data'}
                                moduleObj = DeepLearningClassifierModels();
                         end

                    % Click Detector or Soundtrap Click Detector Module
                    case {'Click Detector', 'SoundTrap Click Detector'}
                        switch fileInfo.fileHeader.streamName
                            case 'Clicks'
                                moduleObj = Click();
                            case 'Trigger Background'
                                moduleObj = ClickTrigger();
                        end
                        
                    case 'GPL Detector'
                        switch fileInfo.fileHeader.streamName
                            case 'GPL Detections'
                                moduleObj = GPL();
                                % TODO: specify objectType
                        end

                    % Right Whale Edge Detector Module
                    case 'RW Edge Detector'
                        moduleObj = RWEdge();
                        disp('Right Whale Edge Detector binary file detected');
                        disp('Note that the low, high and peak frequencies are actually');
                        disp('saved as FFT slices.  In order to convert values to Hz, they');
                        disp('must be multiplied by (sampleRate/fftLength)');

                    % Whistle And Moans Module
                    case 'WhistlesMoans'
                        moduleObj = WhistleAndMoan();

                    % Ipi module
                    case 'Ipi module'
                        moduleObj = SpermWhaleIPI();

                    case 'Gemini Threshold Detector'
                        moduleObj = GeminiThreshold();
                        
                    % Note: PamRawDataBlock has it's own Binary Store (RawDataBinarySource),
                    % but it is created by multiple different processes so doesn't have one
                    % particular type, and may have a type shared with a different binary
                    % store (e.g. the DbHt module creates both a DbHtDataSource and a
                    % RawDataBinarySource, and they will both have type 'DbHt').
                    % The comments in the class indicate that the binary store should never
                    % be used for raw data and that the sole purpose of the class is to
                    % enable sending raw data over the network.  If this is ever changed
                    % and raw data is allowed to be stored in the binary files, we will
                    % have to come up with a way of determining where the raw data came
                    % from besides querying the type.

                    otherwise
                        disp(['Don''t recognize type ' fileInfo.fileHeader.moduleType '.  Aborting load']);
                        break;
                end

                
            case -2
                % Case 2: File Footer.  The file version should have been set
                % when we read the file header.  If the file header is empty,
                % something has gone wrong so warn the user and exit
                if (isempty(fileInfo.fileHeader))
                    disp('Error: found file footer before file header.  Aborting load');
                    break;
                end
                fileInfo.fileFooter = StandardFileFooter().read(fid, [], fileInfo, length, identifier);
            case -3
                % Case 3: Module Header.  The correct function handle should
                % have been set when we read the file header.  If the file
                % header is empty, something has gone wrong so warn the user
                % and exit
                if (isempty(fileInfo.fileHeader))
                    disp('Error: found module header before file header.  Aborting load');
                    break;
                end
                fileInfo.moduleHeader = moduleObj.header().read(fid, [], fileInfo, length, identifier);

            case -4
                % Case 4: Module Footer.  The correct function handle should
                % have been set when we read the file header.  If the file
                % header is empty, something has gone wrong so warn the user
                % and exit
                if (isempty(fileInfo.fileHeader))
                    disp('Error: found module footer before headers.  Aborting load');
                    break;
                end
                fileInfo.moduleFooter = moduleObj.footer().read(fid, [], fileInfo, length, identifier);
            case -5
                % Case 5: Datagram. Skip it for now.
                fseek(fid, length - 8, 'cof');
            
            otherwise
                % Case 6: Data/Background.  The correct moduleObj should have been
                % set when we read in the file header.  If the file header is
                % empty, something has gone wrong so warn the user and exit
                if (isempty(fileInfo.fileHeader) || isempty(fileInfo.moduleHeader))
                    disp('Error: found data before headers.  Aborting load');
                end
                isBackground = identifier == -6;
                dataPoint = struct();

                try
                    [dataPoint, selState] = moduleObj.read(fid, dataPoint, fileInfo, length, identifier);
                catch mError
                    disp(['Error reading ' fileInfo.fileHeader.moduleType '  data object.  Data read:']);
                    disp(dataPoint);
                    disp(getReport(mError));
                end

                % see if it's in the specified list of wanted UID's
                % if ~isempty(uidList)
                %     try
                %         dataUID = dataPoint.UID;
                %         % if dataUID > uidList(end)
                %         %     break;
                %         % end
                %         selState = sum(dataUID == uidList);
                %     catch

                %     end
                % end

                % if channelmap>0 && channelmap~=dataPoint.channelMap
                %     continue;
                % end

                % if selState > 0
                %     selState = filterfun(dataPoint);
                % end

                % if (selState == 0) % skip
                %     continue;
                % elseif (selState == 2) % stop
                %     break;
                % end

                % add to the data or background variables accordingly
                if isBackground
                    nBackground = nBackground + 1;
                    background = checkArrayAllocation(background, nBackground, dataPoint);
                    background(nBackground) = dataPoint;
                else
                    nData = nData + 1;
                    dataSet = checkArrayAllocation(dataSet, nData, dataPoint);
                    dataSet(nData) = dataPoint;
                end
            % reconcile file position with what we expect
            if ftell(fid) ~= nextPos
                fprintf('Error in file position: %d bytes\n', ftell(fid)-nextPos);
                fseek(fid, nextPos - ftell(fid), 'cof');
            end
        end
        if (selState == 2)
            break;
        end
    end
    % due to preallocation it's likely the array is now far too large so
    % shrink it back to the correct size.
    dataSet = dataSet(1:nData);
    background = background(1:nBackground);
catch mError
    disp('Error reading file');
    disp(getReport(mError));
end

if nBackground > 0
    fileInfo.background = background;
end

if ~isempty(moduleObj.objectType)
    fileInfo.objectType = moduleObj.objectType;
end

% close the file and return to the calling function
try
    fclose(fid);
catch
end
return;
end


% Check the array allocation. This gets called every time data are read and
% will extend the array by approximately the sqrt of the arrays own length
% if required. Preallocation acheived by sticking a sample object at a high
% data index so that array up to that point gets filled with nulls.
function array = checkArrayAllocation(array, reqLength, sampleObject)
if isempty(array)
    currentLength = 0;
    clear array;
else
    currentLength = numel(array);
end
if (currentLength >= reqLength)
    return;
end
allocStep = round(sqrt(reqLength));
allocStep = max(10, min(allocStep, 10000));
array(reqLength + allocStep) = sampleObject;
return;
end
