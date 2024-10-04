# PAMGuardMatlab

PAMGuard binary files contains detections such as clicks, whistle contours, deep learning detections, noise, long term spectral averages etc. Binary files provide an efficient and very fast data management system but are not human readable. The `PAMGuard-MATLAB` library is a set of functions that allows the importing of PAMGuard binary files directly into MATLAB.

### Installation

`PAMGuard-MATLAB` needs to be downloaded from here (or via a git client e.g. the integrated one in MATLAB) and added to you MATLAB path

### Tutorial

The core function of this library is `loadPamguardBinaryFile`. This loads any PAMGuard binary file, automatically figures out what type of data it contains and then imports the data into a struct with relevant field names. Usage is straightforward, simply point the function to the correct file. 

```matlab
binaryfile= './Files/SomeBinaryFile.pgdf'
[binarydata, fileinfo]= loadPamguardBinaryFile(myBinaryFile)
```

`fileinfo` contains information about the binary file e.g. when it was created, what version of PAMGuard was used to process the data. `binarydata` is a struct with relevant field names. Some of these field names are consistent across different types of detections e.g. millis, date, UID and others are unique to the particular detection. 

An example of the fields from a click detection are:

**millis:** the start time of the click in milliseconds; this number can be
converted to a date/time with millisecond accuracy.

**date:** the start time of the click in MATLAB datenum format. Use datastr(date)
to show a time string.

**UID:**  a unique serial number for the
detection. Within a processed dataset no other detection will have this number.

**startSample:** The first sample of this click- often used for
finer scale time delay measurements. Samples refers to the number of samples in
total the sound card has taken since processing begun.

**channelMap:** The channel map for this click. One number which
represents which channels this click detection is from: To get the true
channels use the *getChannels(channelMap)* function.

**triggerMap:** which channel triggered the detection.

**type:** Classification type. Must use database or settings to see what species
this refers to.

**duration:** Duration of this click detection in samples.

**nChan:** Number of channels the
detection was made on.

**wave:** Waveform data for each channel.

There are a few additional options for `loadPamguardBinaryFile`.

Time ranges to load can be defined. 

```matlab
timerange = [datenum('2020-03-19 20:00:00', 'yyyy-mm-dd HH:MM:SS'),...
 datenum('2020-03-19 21:00:00', 'yyyy-mm-dd HH:MM:SS')];
[binarydata, fileinfo]= loadPamguardBinaryFile(myBinaryFile, 'timerange', timerange)
```

UID's are unique serial numbers for each detection. They are sequential and users can define values to load via. 

```matlab
uids = 3456:8679;
[binarydata, fileinfo]= loadPamguardBinaryFile(myBinaryFile, 'uidlist', uids)
```

Some files can have multiple channel groups. Each channel group can contain one or more channels of data. To load detections with a specific channel map use. 

```matlab
channel = 3; %channel map
[binarydata, fileinfo]= loadPamguardBinaryFile(myBinaryFile, 'channel', channel)
```

If you don't know the bitmap then you can create it using a list of channels via 

```matlab
function [channelMap] = makeChannelList(channels)
%MAKECHANNELLIST Make a channel bitmap from list. 
%   [CHANNELMAP] = MAKECHANNELLIST(CHANNELS) makes a channel bitmap from a
%   list of channels. Noted channel numbers are from zero, not one. 

channelMap=0;
for i=1:length(channels)
    channelMap = channelMap +  bitsll(1,channels(i));
end
```

Finally, there is an option to define a custom filter for data using

```matlab
myfilter = @myfilterfunction;

[binarydata, fileinfo]= loadPamguardBinaryFile(myBinaryFile, 'filter', myfilter);

function [passed] = myfilterfunction(dataunit)
    passed=false;
    if (length(dataunit.wave)>100)
        passed =true;
    end
end
```

### Load a folder of data

There is a convenience function to load a folder of binary files. Folders contain a mix of data from different detections in PAMGuard and so the load folder function requires a `filemask` input to define which type of data to import. Below shows an example to load a folder of whistle contours. 

```matlab
binaryfolder= './Files/SomeBinaryFolder'
filemask='WhistlesMoans_*.pgdf';
whistles = loadPAMGuardBinaryFolder(binaryfolder,filemask);
```

To load different types of detections change the `filemask` variable to a filename identifier that is unique to the detection type. 

### Compatibility

PAMGuard-MATLAB should be compatible with Pamguard v2.00.15 and earlier.
