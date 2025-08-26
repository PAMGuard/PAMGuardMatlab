function header = readClickTriggerHeader(file)
% reads module header information for the LTSA module

header=readStdModuleHeader(file);
if (header.binaryLength~=0)
    header.channelMap = fread(file, 1, 'int32');
    nChan = countChannels(header.channelMap);
    header.calibration = fread(file, nChan, 'float32');
else 
    header.calibration = [];
end