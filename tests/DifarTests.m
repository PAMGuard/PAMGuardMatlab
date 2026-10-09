% Unit tests for reading DIFAR binary files at module version 3.
%
% From version 3, DIFAR clips no longer carry a crossing tail. Crossings
% live in the database only. These tests check that the reader takes the
% shorter clip and stays aligned to the end of the file.
%
% The test file holds 25 clips of Antarctic blue whale FM calls recorded on
% 7 March 2013, 22:04 to 22:59 UTC, during the Antarctic Blue Whale Voyage.
% The audio is public, in the 2013-03-08 folder of
% https://data.aad.gov.au/metadata/AAS_4102_Audio2013
%
% The expected values below were decoded independently of pgmatlab, by
% walking the file's chunks byte by byte.
%
% Run from the tests/ folder:
%   runtests('DifarTests')

classdef DifarTests < matlab.unittest.TestCase
    properties
        v3File;
        data;
        fileInfo;
        loaderOutput;
    end

    methods (TestClassSetup)
        function loadFile(testCase)
            testsDir = fileparts(mfilename('fullpath'));
            rootDir = fileparts(testsDir);
            addpath(fullfile(rootDir, 'pgmatlab'));
            testCase.v3File = fullfile(rootDir, 'testing-resources', 'data', ...
                'processing', 'difar', 'difar_v3_test1.pgdf');
            testCase.fatalAssertTrue(isfile(testCase.v3File), ...
                sprintf('Test file not found: %s', testCase.v3File));
            testCase.loaderOutput = evalc( ...
                '[testCase.data, testCase.fileInfo] = pgmatlab.loadPamguardBinaryFile(testCase.v3File);');
            testCase.fatalAssertNotEmpty(testCase.data, ...
                'No clips were read from the test file.');
        end
    end

    methods (Test)
        function testModuleVersion(testCase)
            testCase.verifyEqual(testCase.fileInfo.moduleHeader.version, 3);
        end

        function testNoPositionErrors(testCase)
            % A reader that expects a crossing tail reads past the end of
            % each clip. The loader then reports a position error and
            % skips to the next clip, so the misread shows up here.
            testCase.verifyEmpty(strfind(testCase.loaderOutput, ...
                'Error in file position'), testCase.loaderOutput);
        end

        function testReadsEveryClip(testCase)
            % The file footer's nObjects is not used here: PAMGuard
            % currently writes twice the true count (50 for this file).
            testCase.verifyNumElements(testCase.data, 25);
            testCase.verifyTrue(isfield(testCase.fileInfo, 'fileFooter'));
        end

        function testFirstAndLastClip(testCase)
            first = testCase.data(1);
            testCase.verifyEqual(first.clipStart, 1362693895081);
            testCase.verifyEqual(first.demuxedLength, 1087);
            testCase.verifyEqual(first.selAngle, 314, 'AbsTol', 0.01);
            testCase.verifyEqual(first.speciesCode, 'bw_fm');

            last = testCase.data(end);
            testCase.verifyEqual(last.clipStart, 1362697198892);
            testCase.verifyEqual(last.demuxedLength, 784);
            testCase.verifyEqual(last.selAngle, 298, 'AbsTol', 0.01);
            testCase.verifyEqual(last.speciesCode, 'bw_fm');
        end

        function testClipAudioShape(testCase)
            for i = 1:numel(testCase.data)
                clip = testCase.data(i);
                testCase.verifySize(clip.demuxData, [clip.demuxedLength 3], ...
                    sprintf('Clip %d', i));
            end
        end

        function testNoCrossingFields(testCase)
            fields = {'numMatches', 'latitude', 'longitude', 'errors', ...
                'matchChan', 'matchTime'};
            for i = 1:numel(fields)
                testCase.verifyFalse(isfield(testCase.data, fields{i}), ...
                    sprintf('Unexpected field %s', fields{i}));
            end
        end
    end
end
