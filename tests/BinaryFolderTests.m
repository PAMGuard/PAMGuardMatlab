classdef BinaryFolderTests < matlab.unittest.TestCase
    properties
        testsFolder = 'tests';
        resourcesFolder = 'testing-resources';
        dataFolder = 'data';
        codeFolder = 'src';
        
        rootDir;
        testsDir;
        resourcesDir;
        dataDir;
        codeDir;
    end
    
    properties (TestParameter)
        folderFilters = {
            struct('fileMask', '*.pgdf', 'verbose', 0, 'filterfun', 0);
            struct('fileMask', '*.pgdx', 'verbose', 0, 'filterfun', 0);
            struct('fileMask', '*.pgnf', 'verbose', 0, 'filterfun', 0);
            struct('fileMask', '*.pgdf', 'verbose', 1, 'filterfun', 0);
            struct('fileMask', '*.pgdf', 'verbose', 0, 'filterfun', @testUtils.myFilter);
            struct('fileMask', '*.pgdf', 'verbose', 0, 'filterfun', 0, 'uidrange', [1,10], 'sorted', 1);
            struct('fileMask', '*.pgdf', 'verbose', 0, 'filterfun', 0, 'channel', 1);
            struct('fileMask', '*.pgdf', 'verbose', 0, 'filterfun', 0, 'uidlist', [500001]);
        }

        testFolders = {
            struct('folder', 'detectors/click');
            struct('folder', 'detectors/gpl');
            struct('folder', 'processing/clipgenerator');
            struct('folder', 'processing/difar');
        }
    end
    
    methods
        function obj = BinaryFolderTests()
            obj.testsDir = pwd;
            obj.rootDir = fileparts(obj.testsDir);
            obj.resourcesDir = fullfile(obj.rootDir, obj.resourcesFolder);
            obj.dataDir = fullfile(obj.resourcesDir, obj.dataFolder);
            obj.codeDir = fullfile(obj.rootDir, obj.codeFolder);

            disp("RUNNING BINARY FOLDER TESTS WITH THE FOLLOWING CONFIGURATION")
            disp("Test Directory: " + obj.testsDir);
            disp("Root Directory: " + obj.rootDir);
            disp("Data Directory: " + obj.dataDir);
            disp("Code Directory: " + obj.codeDir);
        end
    end

    methods(Test)
        function testLoadBinaryFolder(testCase, testFolders, folderFilters)
            addpath(genpath(testCase.codeDir));
            
            folderPath = fullfile(testCase.dataDir, testFolders.folder);
            
            if ~exist(folderPath, 'dir')
                testCase.assumeFail(sprintf('Test folder does not exist: %s', folderPath));
                return;
            end
            
            fileMask = folderFilters.fileMask;
            verbose = folderFilters.verbose;
            filterfun = folderFilters.filterfun;
            
            varargin = {};
            iArg = 1;
            
            fields = fieldnames(folderFilters);
            for i = 1:length(fields)
                fieldName = fields{i};
                if ~ismember(fieldName, {'fileMask', 'verbose', 'filterfun'})
                    varargin{iArg} = fieldName;
                    varargin{iArg+1} = folderFilters.(fieldName);
                    iArg = iArg + 2;
                end
            end
            
            fprintf('Testing folder: %s with mask: %s\n', folderPath, fileMask);
            
            tic;
            if nargout == 1
                allData = pgmatlab.loadPamguardBinaryFolder(folderPath, fileMask, verbose, filterfun, varargin{:});
                testCase.verifyClass(allData, 'struct');
            elseif nargout == 2
                [allData, allBackground] = pgmatlab.loadPamguardBinaryFolder(folderPath, fileMask, verbose, filterfun, varargin{:});
                testCase.verifyClass(allData, 'struct');
                if ~isempty(allBackground)
                    testCase.verifyClass(allBackground, 'struct');
                end
            else
                [allData, allBackground, fileInfos] = pgmatlab.loadPamguardBinaryFolder(folderPath, fileMask, verbose, filterfun, varargin{:});
                testCase.verifyClass(allData, 'struct');
                if ~isempty(allBackground)
                    testCase.verifyClass(allBackground, 'struct');
                end
                testCase.verifyClass(fileInfos, 'struct');
            end
            loadTime = toc;
            
            if ~isempty(allData)
                testCase.verifyTrue(isfield(allData, 'fileName'), 'Data should have fileName field');
                
                if isfield(folderFilters, 'channel')
                    channelMask = folderFilters.channel;
                    for i = 1:length(allData)
                        if isfield(allData(i), 'channels')
                            testCase.verifyTrue(bitand(allData(i).channels, channelMask) > 0, 'Data should match channel filter');
                        end
                    end
                end
                
                if isfield(folderFilters, 'uidrange')
                    uidRange = folderFilters.uidrange;
                    for i = 1:length(allData)
                        testCase.verifyGreaterThanOrEqual(allData(i).UID, uidRange(1), 'UID should be >= range start');
                        testCase.verifyLessThanOrEqual(allData(i).UID, uidRange(2), 'UID should be <= range end');
                    end
                end
                
                if isfield(folderFilters, 'uidlist')
                    uidList = folderFilters.uidlist;
                    for i = 1:length(allData)
                        testCase.verifyTrue(ismember(allData(i).UID, uidList), 'UID should be in uidlist');
                    end
                end
            end
            
            fprintf('Loaded %d data points in %.4f seconds\n', length(allData), loadTime);
        end
        
        function testEmptyFolder(testCase)
            addpath(genpath(testCase.codeDir));
            
            tempDir = fullfile(tempdir, 'empty_test_folder');
            if exist(tempDir, 'dir')
                rmdir(tempDir, 's');
            end
            mkdir(tempDir);
            
            [allData, allBackground, fileInfos] = pgmatlab.loadPamguardBinaryFolder(tempDir, '*.pgdf', 0, 0);
            
            testCase.verifyEmpty(allData, 'Empty folder should return empty data');
            testCase.verifyEmpty(allBackground, 'Empty folder should return empty background');
            testCase.verifyEmpty(fileInfos, 'Empty folder should return empty fileInfos');
            
            rmdir(tempDir);
        end
    end
end