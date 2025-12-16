function [dataSet, fileInfo, selState] = loadPamguardBinaryFile(fileName, varargin)
%PGMATLAB.LOADPAMGUARDBINARYFILE - Load a <a href="https://www.pamguard.org/olhelp/utilities/BinaryStore/docs/binarystore_overview.html">PAMGuard Binary File</a> into memory.
%   Produces a 1x2 vector with structs of the data set and file information.
%
%   Syntax
%       [dataSet, fileInfo] = PGMATLAB.LOADPAMGUARDBINARYFILE(fileName, varargin)
%       dataSet = PGMATLAB.LOADPAMGUARDBINARYFILE(fileName, varargin)
%   
%       varargin can be one or more of the following options:
%
%           'timerange', TIME_RANGE: Specify the time range to load data from.
%               TIME_RANGE is a 1x2 vector of the form [START_TIME, END_TIME].
%
%           'uidrange', UID_RANGE: Specify the UID range to load data from.
%               UID_RANGE is a 1x2 vector of the form [START_UID, END_UID].
%
%           'uidlist', UID_LIST: Specify a list of UIDs to load data from.
%               UID_LIST is a vector of UIDs.
%
%           'filter', FILTER_FUN: Specify a filter function to apply to the data.
%               FILTER_FUN is a function handle that takes the data as input and
%               returns a selection state (0 = skip, 1 = keep, 2 = stop, if data
%               is ordered).
%
%           'channel', CHANNEL_MAP: Specify a channel map to apply to the data.
%               CHANNEL_MAP a bitmap of the channels to load.
%
%           'sorted', SORTED: Specify whether the data is sorted. SORTED is a 
%               logical value (1 true or 0 false). It serves to speed up execution
%               if the data exceeds the upper bound of a range filter. This applies
%               if 'timerange' and/or 'uidrange' are provided. Setting SORTED to 1
%               when using these range filters can cause unexpected behaviour if the
%               data being filtered on is not actually sorted. Defaults to 0 (false).
%
%   Example 1: load an entire binary file
%       >>> [d,f] = pgmatlab.loadPamguardBinaryFile("./data.pgdf")
%   
%   Example 2: load a specific time range (indicating sorted data)
%       >>> startTime = datenum(2017,10,21,0,25,0);
%       >>> endTime = datenum(2017,10,21,0,26,0);
%       >>> [d,f] = pgmatlab.loadPamguardBinaryFile("./data.pgdf", 'timerange', [startTime endTime], 'sorted', 1)
%   
%   Example 3: load a specific UID range
%       >>> [d,f] = pgmatlab.loadPamguardBinaryFile("./data.pgdf", 'uidrange', [1000345 1000345])
%   
%   Example 4: load a specific list of UIDs
%       >>> [d,f] = pgmatlab.loadPamguardBinaryFile("./data.pgdf", 'uidlist', [1000345 1000347 1000348])
%   
%   Example 5: load a specific channel map
%       >>> [d,f] = pgmatlab.loadPamguardBinaryFile("./data.pgdf", 'channel', [0 1])
%   
%   Example 6: load a specific channel map
%       >>> [d,f] = pgmatlab.loadPamguardBinaryFile("./data.pgdf", 'sorted', true)
%
%   Example 7: filter based on an un-sorted parameter
%       >>> function selState = myFilter(data)
%               % remove all data where type ~= 0
%               if data.type == 1
%                   selState = 1; % keep
%               else
%                   selState = 0; % skip
%               end
%       >>> end
%       >>> [d,f] = pgmatlab.loadPamguardBinaryFile("./data.pgdf", 'filter', @myFilter)
%
%   Example 8: filter based on a sorted parameter
%       >>> function selState = myFilter(data)
%               % remove all data where type ~= 0
%               if data.type == 1
%                   selState = 1; % keep
%               else
%                   selState = 2; % stop
%               end
%       >>> end
%       >>> [d,f] = pgmatlab.loadPamguardBinaryFile("./data.pgdf", 'filter', @myFilter, 'sorted', 1)
%
%   See also PGMATLAB.LOADPAMGUARDBINARYFOLDER, PGMATLAB.LOADPAMGUARDMULTIFILE.
%

import pgmatlab.utils.*;
import pgmatlab.core.annotations.*;
import pgmatlab.core.modules.*;
import pgmatlab.core.standard.*;

dataSet = [];
fileInfo = [];
nBackground = 0;
timeRange = [-Inf +Inf];
uidRange = [-Inf +Inf];
uidList = [];
iArg = 0;
sorted = 0;
filterfun = @pgmatlab.utils.passalldata;
channelmap=-1;
while iArg < numel(varargin)
    iArg = iArg + 1;
    switch(varargin{iArg})
        case 'timerange'
            iArg = iArg + 1;
            %            timeRange = pgmatlab.utils.dateNumToMillis(varargin{iArg});
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
        case 'sorted'
            iArg = iArg + 1;
            sorted = varargin{iArg};
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

    moduleObj = -1;


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
                fileInfo.fileHeader = pgmatlab.core.standard.StandardFileHeader().read(fid, [], fileInfo, length, identifier);

                switch fileInfo.fileHeader.moduleType

                    % AIS Processing Module
                    case 'AIS Processing'
                        moduleObj = pgmatlab.core.modules.processing.AIS();

                        % Clip Generator Module
                    case 'Clip Generator'
                        moduleObj = pgmatlab.core.modules.processing.ClipGenerator();
                    
                    % Gibbon detector (private plugin)
                    case 'Gibbon Detector'
                        switch fileInfo.fileHeader.streamName
                            case 'Gibbon Results'
                                moduleObj = pgmatlab.core.modules.processing.GibbonResult();
                        end

                        % DbHt Module
                    case 'DbHt'
                        moduleObj = pgmatlab.core.modules.processing.DbHt();

                        % % Difar Module
                    case 'DIFAR Processing'
                        moduleObj = pgmatlab.core.modules.processing.Difar();

                        % Ishmael Data & Detections
                    case {'Energy Sum Detector','Spectrogram Correlation Detector','Matched Filter Detector'}
                        switch fileInfo.fileHeader.streamName
                            case 'Ishmael Peak Data'
                                moduleObj = pgmatlab.core.modules.processing.IshmaelData();
                                % TODO: specify objectType
                            case 'Ishmael Detections'
                                moduleObj = pgmatlab.core.modules.processing.IshmaelDetections();
                                % TODO: specify objectType
                        end

                        % LTSA Module
                    case 'LTSA'
                        moduleObj = pgmatlab.core.modules.processing.LongTermSpectralAverage();

                        % Filtered Noise Measurement Module (Noise One Band)
                    case 'NoiseBand'
                        moduleObj = pgmatlab.core.modules.processing.NoiseBand();

                        % Noise Monitor Module and Noise Band Monitor Module
                        % Note: The two modules have different types, but both
                        % use noiseMonitor.NoiseBinaryDataSource class to save
                        % data
                    case {'Noise Monitor', 'Noise Band'}
                        moduleObj = pgmatlab.core.modules.processing.NoiseMonitor();

                        % Deep learning module
                    case 'Deep Learning Classifier'
                        switch fileInfo.fileHeader.streamName
                            case {'DL_detection', 'DL detection'}
                                moduleObj = pgmatlab.core.modules.classifiers.DeepLearningClassifierDetections();
                            case {'DL_Model_Data', 'DL Model Data'}
                                moduleObj = pgmatlab.core.modules.classifiers.DeepLearningClassifierModels();
                        end

                        % Click Detector or Soundtrap Click Detector Module
                    case {'Click Detector', 'SoundTrap Click Detector'}
                        switch fileInfo.fileHeader.streamName
                            case 'Clicks'
                                moduleObj = pgmatlab.core.modules.detectors.Click();
                            case 'Trigger Background'
                                moduleObj = pgmatlab.core.modules.detectors.ClickTrigger();
                        end

                    case 'GPL Detector'
                        switch fileInfo.fileHeader.streamName
                            case 'GPL Detections'
                                moduleObj = pgmatlab.core.modules.detectors.GPL();
                            case 'GPL State'
                                moduleObj = pgmatlab.core.modules.detectors.GPLState();
                        end

                        % Right Whale Edge Detector Module
                    case 'RW Edge Detector'
                        moduleObj = pgmatlab.core.modules.detectors.RWEdge();
                        disp('Right Whale Edge Detector binary file detected');
                        disp('Note that the low, high and peak frequencies are actually');
                        disp('saved as FFT slices.  In order to convert values to Hz, they');
                        disp('must be multiplied by (sampleRate/fftLength)');

                        % Whistle And Moans Module
                    case 'WhistlesMoans'
                        moduleObj = pgmatlab.core.modules.detectors.WhistleAndMoan();

                        % Ipi module
                    case 'Ipi module'
                        moduleObj = pgmatlab.core.modules.plugins.SpermWhaleIPI();

                    case 'Gemini Threshold Detector'
                        moduleObj = pgmatlab.core.modules.plugins.GeminiThreshold();

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
                fileInfo.fileFooter = pgmatlab.core.standard.StandardFileFooter().read(fid, [], fileInfo, length, identifier);
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
                    [dataPoint, selState] = moduleObj.read(fid, dataPoint, fileInfo, length, identifier, timeRange, uidRange, uidList, channelmap);
                catch mError
                    disp(['Error reading ' fileInfo.fileHeader.moduleType '  data object.  Data read:']);
                    disp(dataPoint);
                    disp(getReport(mError));
                end

                % Allow custom filters to be applied
                if selState == 1
                    selState = filterfun(dataPoint);
                end

                % If the selState is 2 (STOP) and the data is sorted then
                % stop reading the file. If the data is not sorted, then
                % selState 0 (SKIP) and 2 (STOP) both mean 'SKIP'. If
                % selState is 1 (KEEP), we keep the data point.
                if (selState == 2 && sorted)
                    break;
                elseif (selState ~= 1)
                    if (~sorted)
                        selState = 0;
                    end
                    fseek(fid, nextPos - ftell(fid), 'cof');
                    continue;
                end

                % add to the data or background variables accordingly
                if isBackground
                    nBackground = nBackground + 1;
                    background = pgmatlab.utils.checkArrayAllocation(background, nBackground, dataPoint);
                    background(nBackground) = dataPoint;
                else
                    nData = nData + 1;
                    dataSet = pgmatlab.utils.checkArrayAllocation(dataSet, nData, dataPoint);
                    dataSet(nData) = dataPoint;
                end

                % reconcile file position with what we expect
                if ftell(fid) ~= nextPos
                    fprintf('Error in file position: %d bytes\n', ftell(fid)-nextPos);
                    fseek(fid, nextPos - ftell(fid), 'cof');
                end
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
