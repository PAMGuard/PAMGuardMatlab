classdef MultiFileTests < matlab.unittest.TestCase
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
        multiFileParams = {
            struct('fileNames', {{'click_v4_test1.pgdf'}}, 'UIDs', [1]);
            struct('fileNames', {{'click_v4_test1.pgdf', 'click_v4_test2.pgdf'}}, 'UIDs', [1, 2]);
            struct('fileNames', {{'gpl_v2_test1.pgdf'}}, 'UIDs', [500001]);
            struct('fileNames', {{'gpl_v2_test1.pgdf', 'gpl_v2_test2.pgdf'}}, 'UIDs', [500001, 500002]);
            struct('fileNames', {{'click_v4_test1.pgdf', 'click_v4_test1.pgdf'}}, 'UIDs', [1, 2]);
            struct('fileNames', {{'deeplearningclassifier_v2_test1_detections.pgdf'}}, 'UIDs', [5000001]);
            struct('fileNames', {{'whistleandmoan_v2_test1.pgdf'}}, 'UIDs', [300001]);
        }
        
        verbosityLevels = {
            struct('verbose', 0);
            struct('verbose', 1);
        }
    end
    
    methods
        function obj = MultiFileTests()
            obj.testsDir = pwd;
            obj.rootDir = fileparts(obj.testsDir);
            obj.resourcesDir = fullfile(obj.rootDir, obj.resourcesFolder);
            obj.dataDir = fullfile(obj.resourcesDir, obj.dataFolder);
            obj.codeDir = fullfile(obj.rootDir, obj.codeFolder);

            disp("RUNNING MULTI-FILE TESTS WITH THE FOLLOWING CONFIGURATION")
            disp("Test Directory: " + obj.testsDir);
            disp("Root Directory: " + obj.rootDir);
            disp("Data Directory: " + obj.dataDir);
            disp("Code Directory: " + obj.codeDir);
        end
    end

    methods(Test)
        function testLoadMultiFile(testCase, multiFileParams, verbosityLevels)
            addpath(genpath(testCase.codeDir));
            
            fileNames = multiFileParams.fileNames;
            UIDs = multiFileParams.UIDs;
            verbose = verbosityLevels.verbose;
            
            testCase.verifyEqual(length(fileNames), length(UIDs), 'fileNames and UIDs must have same length');
            
            fprintf('Testing multi-file load with %d files and UIDs: [%s]\n', ...
                length(fileNames), sprintf('%d ', UIDs));
            
            tic;
            eventData = pgmatlab.loadPamguardMultiFile(testCase.dataDir, fileNames, UIDs, verbose);
            loadTime = toc;
            
            testCase.verifyClass(eventData, 'struct', 'eventData should be a struct array');
            
            if ~isempty(eventData)
                testCase.verifyTrue(isfield(eventData, 'binaryFile'), 'Data should have binaryFile field');
                
                loadedUIDs = [eventData.UID];
                expectedUIDs = UIDs;
                
                testCase.verifyTrue(all(ismember(loadedUIDs, expectedUIDs)), ...
                    'All loaded UIDs should be in the requested UIDs list');
                
                for i = 1:length(eventData)
                    testCase.verifyTrue(~isempty(eventData(i).binaryFile), ...
                        'Each data point should have a non-empty binaryFile field');
                end
                
                uniqueFiles = unique({eventData.binaryFile});
                fprintf('Loaded %d data points from %d files in %.4f seconds\n', ...
                    length(eventData), length(uniqueFiles), loadTime);
            else
                fprintf('No data found for the specified files and UIDs\n');
            end
        end
        
        function testInvalidFileNames(testCase)
            addpath(genpath(testCase.codeDir));
            
            fileNames = {'nonexistent_file.pgdf'};
            UIDs = [1];
            
            eventData = pgmatlab.loadPamguardMultiFile(testCase.dataDir, fileNames, UIDs, 0);
            
            testCase.verifyEmpty(eventData, 'Non-existent files should return empty data');
        end
        
        function testMismatchedArrays(testCase)
            addpath(genpath(testCase.codeDir));
            
            fileNames = {'click_v4_test1.pgdf', 'click_v4_test2.pgdf'};
            UIDs = [1]; % Mismatched length
            
            testCase.verifyError(@() pgmatlab.loadPamguardMultiFile(testCase.dataDir, fileNames, UIDs, 0), ...
                '', 'Should error when fileNames and UIDs have different lengths');
        end
        
        function testEmptyArrays(testCase)
            addpath(genpath(testCase.codeDir));
            
            fileNames = {};
            UIDs = [];
            
            eventData = pgmatlab.loadPamguardMultiFile(testCase.dataDir, fileNames, UIDs, 0);
            
            testCase.verifyEmpty(eventData, 'Empty input arrays should return empty data');
        end
        
        function testNonExistentUIDs(testCase)
            addpath(genpath(testCase.codeDir));
            
            fileNames = {'click_v4_test1.pgdf'};
            UIDs = [999999]; % UID that likely doesn't exist
            
            eventData = pgmatlab.loadPamguardMultiFile(testCase.dataDir, fileNames, UIDs, 1);
            
            testCase.verifyEmpty(eventData, 'Non-existent UIDs should return empty data');
        end
        
        function testDuplicateFiles(testCase)
            addpath(genpath(testCase.codeDir));
            
            fileNames = {'click_v4_test1.pgdf', 'click_v4_test1.pgdf'};
            UIDs = [1, 2];
            
            eventData = pgmatlab.loadPamguardMultiFile(testCase.dataDir, fileNames, UIDs, 0);
            
            if ~isempty(eventData)
                testCase.verifyTrue(all(strcmp({eventData.binaryFile}, 'click_v4_test1.pgdf')), ...
                    'All data should come from the same file when duplicates are specified');
            end
        end
        
        function testLargeUIDList(testCase)
            addpath(genpath(testCase.codeDir));
            
            fileNames = repmat({'gpl_v2_test1.pgdf'}, 1, 10);
            UIDs = [500001:500010];
            
            eventData = pgmatlab.loadPamguardMultiFile(testCase.dataDir, fileNames, UIDs, 0);
            
            if ~isempty(eventData)
                testCase.verifyTrue(length(eventData) <= 10, ...
                    'Should not return more data than requested UIDs');
            end
        end
    end
end