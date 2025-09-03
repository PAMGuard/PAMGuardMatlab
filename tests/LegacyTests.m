% test the outputs of pgmatlab code with legacy code to ensure
% consistent interface and data.

classdef LegacyTests < matlab.unittest.TestCase
    properties
        testsFolder = 'tests'; % inside root
        resourcesFolder = 'resources'; % inside root
            dataFolder = 'data'; % inside resources
            legacyFolder = 'v1.0.1code'; % inside resources
        codeFolder = 'src'; % inside root
        
        rootDir;
        testsDir;
        resourcesDir;
            dataDir;
            legacyDir;
        codeDir;
    end
    
    properties (TestParameter)
        % NOTE: the 'sorted' parameter was added in v2 to speed up filtering on sorted date. It defaults to 0
        % to ensure backwards compatibility with pgmaptlab v1.

        filters = {
            struct();
            struct('uidrange', [1,10], 'sorted', 1); 
            struct('uidrange', [5000001,5000009], 'sorted', 1); 
            struct('uidrange', [1 500006], 'sorted', 0)
            struct('uidlist', [500001], 'uidrange', [1 500006], 'sorted', 0)
            struct('uidlist', [500001], 'uidrange', [1 500006], 'channel', 1, 'sorted', 0)
            struct('channel', 4); 
            struct('channel', 1); 
            struct('uidlist', [500001]); 
            struct('uidlist', [500001], 'uidrange', [1 100000]);
            struct('filter', @testUtils.myFilter)
            struct('uidlist', [5000003, 5000004, 5000005, 5000006], 'filter', @testUtils.myFilter)
            struct('uidlist', [5000003, 5000004, 5000005, 5000006], 'filter', @testUtils.myFilter, 'sorted', 1)
        }

        filePath = {
            struct('path', "processing/ais/ais_v1_test1.pgdf"); 
            struct('path', "classifiers/deeplearningclassifier/deeplearningclassifier_v2_test1_detections.pgdf"); 
            struct('path', "classifiers/deeplearningclassifier/deeplearningclassifier_v2_test1_models.pgdf"); 
            struct('path', "detectors/click/click_v4_test2.pgdf"); 
            struct('path', "detectors/click/click_v4_test3.pgdf"); 
            struct('path', "detectors/clicktriggerbackground/clicktriggerbackground_v0_test1.pgdf"); 
            struct('path', "detectors/gpl/gpl_v2_test1.pgdf"); 
            struct('path', "detectors/gpl/gpl_v2_test2.pgdf"); 
            struct('path', "detectors/rwedge/RW_Edge_Detector_Right_Whale_Edge_Detector_Edges_20090328_230139.pgdf"); 
            struct('path', "detectors/whistleandmoan/whistleandmoan_v2_test1.pgdf"); 
            struct('path', "plugins/geminithreshold/geminithreshold_test1.pgdf"); 
            struct('path', "plugins/spermwhaleipi/spermwhaleipi_v1_test1.pgdf"); 
            struct('path', "processing/clipgenerator/clipgenerator_v3_test1.pgdf"); 
            struct('path', "processing/clipgenerator/clipgenerator_v3_test2.pgdf"); 
            struct('path', "processing/dbht/dbht_v2_test1.pgdf"); 
            struct('path', "processing/difar/difar_v2_test1.pgdf"); 
            struct('path', "processing/difar/difar_v2_test2.pgdf"); 
            struct('path', "processing/difar/difar_v2_test3.pgdf"); 
            struct('path', "processing/ishmael/ishmaeldetections_energysum_v2_test1.pgdf"); 
            struct('path', "processing/ishmael/ishmaeldetections_energysum_v2_test2.pgdf"); 
            struct('path', "processing/ishmael/ishmaeldetections_energysum_v2_test3.pgdf"); 
            struct('path', "processing/ishmael/ishmaeldetections_matchedfilter_v2_test1.pgdf"); 
            struct('path', "processing/ishmael/ishmaeldetections_matchedfilter_v2_test2.pgdf"); 
            struct('path', "processing/ishmael/ishmaeldetections_spectrogramcorrelation_v2_test1.pgdf"); 
            struct('path', "processing/ishmael/ishmaeldetections_spectrogramcorrelation_v2_test2.pgdf"); 
            struct('path', "processing/longtermspectralaverage/longtermspectralaverage_v2_test1.pgdf"); 
            struct('path', "processing/noiseband/noiseband_v3_test1.pgdf"); 
            struct('path', "processing/noiseband/noisebandnoise_v3_test1.pgdf"); 
            struct('path', "processing/noiseband/noisebandpulses_v3_test1.pgdf"); 
            struct('path', "processing/noisemonitor/noisemonitor_v2_test1.pgdf"); 
            struct('path', "processing/ais/ais_v1_test1.pgdx");
            struct('path', "classifiers/deeplearningclassifier/deeplearningclassifier_v2_test1_detections.pgdx");
            struct('path', "classifiers/deeplearningclassifier/deeplearningclassifier_v2_test1_models.pgdx");
            struct('path', "detectors/click/click_v4_test1.pgdx");
            struct('path', "detectors/click/click_v4_test2.pgdx");
            struct('path', "detectors/click/click_v4_test3.pgdx");
            struct('path', "detectors/clicktriggerbackground/clicktriggerbackground_v0_test1.pgdx");
            struct('path', "detectors/gpl/gpl_v2_test1.pgdx");
            struct('path', "detectors/gpl/gpl_v2_test2.pgdx");
            struct('path', "detectors/rwedge/RW_Edge_Detector_Right_Whale_Edge_Detector_Edges_20090328_230139.pgdx");
            struct('path', "detectors/whistleandmoan/whistleandmoan_v2_test1.pgdx");
            struct('path', "plugins/geminithreshold/geminithreshold_test1.pgdx");
            struct('path', "plugins/spermwhaleipi/spermwhaleipi_v1_test1.pgdx");
            struct('path', "processing/clipgenerator/clipgenerator_v3_test1.pgdx");
            struct('path', "processing/clipgenerator/clipgenerator_v3_test2.pgdx");
            struct('path', "processing/dbht/dbht_v2_test1.pgdx");
            struct('path', "processing/difar/difar_v2_test1.pgdx");
            struct('path', "processing/difar/difar_v2_test2.pgdx");
            struct('path', "processing/difar/difar_v2_test3.pgdx");
            struct('path', "processing/ishmael/ishmaeldetections_energysum_v2_test1.pgdx");
            struct('path', "processing/ishmael/ishmaeldetections_energysum_v2_test2.pgdx");
            struct('path', "processing/ishmael/ishmaeldetections_energysum_v2_test3.pgdx");
            struct('path', "processing/ishmael/ishmaeldetections_matchedfilter_v2_test1.pgdx");
            struct('path', "processing/ishmael/ishmaeldetections_matchedfilter_v2_test2.pgdx");
            struct('path', "processing/ishmael/ishmaeldetections_spectrogramcorrelation_v2_test1.pgdx");
            struct('path', "processing/ishmael/ishmaeldetections_spectrogramcorrelation_v2_test2.pgdx");
            struct('path', "processing/longtermspectralaverage/longtermspectralaverage_v2_test1.pgdx");
            struct('path', "processing/noiseband/noiseband_v3_test1.pgdx");
            struct('path', "processing/noiseband/noisebandnoise_v3_test1.pgdx");
            struct('path', "processing/noiseband/noisebandpulses_v3_test1.pgdx");
            struct('path', "processing/noisemonitor/noisemonitor_v2_test1.pgdx");
            struct('path', "detectors/click/click_v4_test1.pgnf");
            struct('path', "detectors/click/click_v4_test2.pgnf");
            struct('path', "detectors/click/click_v4_test3.pgnf");
            struct('path', "detectors/gpl/gpl_v2_test1.pgnf");
            struct('path', "detectors/gpl/gpl_v2_test2.pgnf");
            struct('path', "detectors/whistleandmoan/whistleandmoan_v2_test1.pgnf");
            struct('path', "plugins/geminithreshold/geminithreshold_test1.pgnf")'
            };
        end
    methods
        function obj = LegacyTests()
            obj.testsDir = pwd; % assumes running tests from within testsDir
            obj.rootDir = fileparts(obj.testsDir); % one level up (into root)
            obj.resourcesDir = fullfile(obj.rootDir, obj.resourcesFolder);
                obj.dataDir = fullfile(obj.resourcesDir, obj.dataFolder);
                obj.legacyDir = fullfile(obj.resourcesDir, obj.legacyFolder);
            obj.codeDir = fullfile(obj.rootDir, obj.codeFolder);

            disp("RUNNING TESTS WITH THE FOLLOWING CONFIGURATION")
            disp("Test Directory: " + obj.testsDir);
            disp("Root Directory: " + obj.rootDir);
            disp("Data Directory: " + obj.dataDir);
            disp("Legacy Directory: " + obj.legacyDir);
            disp("Code Directory: " + obj.codeDir);
        end
        function [data, fileInfo, time] = runCur(obj, filename, vin)
            % rmpath(obj.legacyDir);
            addpath(genpath(obj.codeDir));
            tic;
            [data, fileInfo] = pgmatlab.loadPamguardBinaryFile(filename, vin{:});
            time = toc;
        end
        function [data, fileInfo, time] = runOld(obj, filename, vin)
            % rmpath(obj.codeDir);
            addpath(obj.legacyDir);    
            tic        
            [data, fileInfo] = loadPamguardBinaryFile(filename, vin{:});
            time = toc;
        end
    end


    methods(Test)
        function testFile(testCase, filePath, filters)
            fp = filePath.path;

            iArg = 1;
            vin = {};

            fields = fieldnames(filters);
            vin_str = "";

            for i = 1:length(fields)
                fieldName = fields{i};
                if ~strcmp(fieldName, 'path')  % exclude the 'path' field
                    vin{iArg} = fieldName;
                    vin{iArg+1} = filters.(fieldName);
                    iArg = iArg + 2;
                    if strcmp(fieldName, "filter")
                        vin_str = vin_str + " " + fieldName + " customFunc";
                    else
                        vin_str = vin_str + " " + fieldName + " " + num2str(filters.(fieldName));
                    end
                end
            end

            relFilePath = fullfile(testCase.dataDir, fp);
            fprintf('Testing %s\n', relFilePath);
            disp(vin_str);

            [newData, newFileInfo, newTime] = testCase.runCur(relFilePath, vin);
            
            [oldData, oldFileInfo, oldTime] = testCase.runOld(relFilePath, vin);
            
            testCase.verifyEqual(newData, oldData);
            fields_to_remove = {'readModuleHeader', 'readModuleFooter', 'readBackgroundData', 'readModuleData'};
            for i = 1:length(fields_to_remove)
                if isfield(oldFileInfo, fields_to_remove{i})
                    oldFileInfo = rmfield(oldFileInfo, fields_to_remove{i});
                end
            end
            testCase.verifyEqual(newFileInfo, oldFileInfo);
            
            % Get file size
            fileSize = dir(relFilePath);
            fileSize = fileSize.bytes;
            
            % % Write results to CSV file
            fid = fopen('results.csv', 'a');
            if ftell(fid) == 0  % check if file is empty
                fprintf(fid, 'File Path,Filters,File Size (bytes),New Time (s),Old Time (s)\n');
            end
            fprintf(fid, '%s,%s,%d,%f,%f\n', relFilePath, vin_str, fileSize, newTime, oldTime);
            fclose(fid);
        end
    end
end