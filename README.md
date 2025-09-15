# PAMGuardMatlab

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.16979862.svg)](https://doi.org/10.5281/zenodo.16979862)

A MATLAB library for loading PAMGuard binary files containing acoustic detection data including clicks, whistle contours, deep learning detections, noise measurements, and spectral data. PAMGuard binary files provide efficient data storage and fast access, but are not human-readable. This library allows you to import PAMGuard binary data directly into MATLAB.

## Installation

1. Go to [GitHub Releases](https://github.com/PAMGuard/PAMGuardMatlab/releases)
2. Download the latest `pgmatlab-{version}.zip` file
3. Extract the ZIP file to your desired location
4. Add the extracted `pgmatlab` folder to your MATLAB path:

```matlab
addpath('path/to/extracted/pgmatlab');
```

5. You only need to add the one pgmatlab folder to your path to use the main PAMGuard binary file functions. 
However, if you're using any of the utility and database functions directly within your own code, 
you'll need to either import the namespaces, import individual functions from within the namespaces, 
or put the full namespace path in every function call:
 
```matlab
import pgmatlab.utils.*; % import PAMGuard utils functions 
import pgmatlab.db.*; % import PAMGuard database functions
```

## Quick Start

Load a single binary file:

```matlab
[data, fileInfo] = loadPamguardBinaryFile('path/to/file.pgdf');
```

Load multiple files from a folder:

```matlab
data = loadPamguardBinaryFolder('path/to/folder', '*.pgdf');
```

Load specific data points across multiple files:

```matlab
fileNames = {'file1.pgdf', 'file2.pgdf'};
uids = [500001, 500002];
eventData = loadPamguardMultiFile('path/to/folder', fileNames, uids);
```

## Core Functions

### `loadPamguardBinaryFile`

The primary function for loading individual PAMGuard binary files. Automatically detects the data type and imports it into a structured format.

**Syntax:**
```matlab
[data, fileInfo, selState] = loadPamguardBinaryFile(filename, ...)
[data, fileInfo] = loadPamguardBinaryFile(filename, ...)
data = loadPamguardBinaryFile(filename, ...)
```

**Parameters:**
- `filename` - Path to the binary file
- Optional name-value pairs:
  - `'timerange', [startTime, endTime]` - Load data within time range
  - `'uidrange', [startUID, endUID]` - Load data within UID range
  - `'uidlist', [uid1, uid2, ...]` - Load specific UIDs
  - `'channel', channelMap` - Load data from specific channels
  - `'filter', @filterFunction` - Apply custom filter function
  - `'sorted', true/false` - Optimize for sorted data (default: false)

**Examples:**

Load entire file:
```matlab
[data, fileInfo] = loadPamguardBinaryFile('detections.pgdf');
```

Load specific time range:
```matlab
startTime = datenum(2023,1,15,10,0,0);
endTime = datenum(2023,1,15,11,0,0);
[data, fileInfo] = loadPamguardBinaryFile('detections.pgdf', ...
    'timerange', [startTime, endTime], 'sorted', true);
```

Load specific UIDs:
```matlab
[data, fileInfo] = loadPamguardBinaryFile('detections.pgdf', ...
    'uidlist', [500001, 500005, 500010]);
```

Apply custom filter:
```matlab
function keep = myFilter(detection)
    keep = detection.amplitude > 0.5;  % Keep high amplitude detections
end

[data, fileInfo] = loadPamguardBinaryFile('detections.pgdf', ...
    'filter', @myFilter);
```

### `loadPamguardBinaryFolder`

Load multiple binary files from a folder using file pattern matching.

**Syntax:**
```matlab
[allData, allBackground, fileInfos] = loadPamguardBinaryFolder(dir, fileMask, verbose, filterfun, ...)
[allData, allBackground] = loadPamguardBinaryFolder(dir, fileMask, verbose, filterfun, ...)
allData = loadPamguardBinaryFolder(dir, fileMask, verbose, filterfun, ...)
```

**Parameters:**
- `dir` - Directory containing binary files
- `fileMask` - File pattern (e.g., '*.pgdf', 'WhistlesMoans_*.pgdf')
- `verbose` - Progress logging interval (0 = no logging)
- `filterfun` - Filter function or 0 for no filtering
- Additional name-value pairs as in `loadPamguardBinaryFile`

**Examples:**

Load all click detections:
```matlab
clickData = loadPamguardBinaryFolder('./Data', 'Click_*.pgdf', 1, 0);
```

Load whistle data with filtering:
```matlab
whistleData = loadPamguardBinaryFolder('./Data', 'WhistlesMoans_*.pgdf', ...
    0, @myFilter, 'channel', 1);
```

### `loadPamguardMultiFile`

Load specific data points from multiple files, useful for event-based analysis.

**Syntax:**
```matlab
eventData = loadPamguardMultiFile(dir, fileNames, UIDs, verbose)
```

**Parameters:**
- `dir` - Directory containing the files
- `fileNames` - Cell array of filenames
- `UIDs` - Array of UIDs to load (parallel to fileNames)
- `verbose` - Progress logging (optional, default: 0)

**Example:**

Load specific detections from multiple files:
```matlab
files = {'clicks_20230115_100000.pgdf', 'clicks_20230115_110000.pgdf'};
uids = [500001, 500123];
eventData = loadPamguardMultiFile('./Data', files, uids, 1);
```



## Supported Modules

PAMGuardMatlab supports the following PAMGuard modules:

**Detectors:**
- Click Detector
- Whistle and Moan Detector
- GPL Detector
- Right Whale Edge Detector

**Classifiers:**
- Deep Learning Classifier

**Processing Modules:**
- AIS Processing
- Clip Generator
- DIFAR Processing
- Long Term Spectral Average (LTSA)
- Noise Band Monitor
- Noise Monitor

**Plugins:**
- Sperm Whale IPI
- Gemini Threshold Detector

## Performance Tips

1. **Use sorted flag** when loading time/UID ranges from chronologically ordered files
2. **Specify file masks** when loading folders to avoid processing unnecessary files
3. **Use filters** to reduce memory usage for large datasets
4. **Load specific channels** rather than all channels when possible

## Utility Functions

To use the functions in +utils you will need to import that folder in every
function that uses this library
```matlab
import pgmatlab.utils.*
```

### Channel Map Functions

Convert channel lists to bitmaps:
```matlab
function channelMap = makeChannelMap(channels)
    channelMap = 0;
    for i = 1:length(channels)
        channelMap = channelMap + bitshift(1, channels(i));
    end
end
```

Extract channels from bitmap:
```matlab
import pgmatlab.utils.*
channels = getChannels(channelMap);
```

### Time Conversion

Convert milliseconds to MATLAB datenum:
```matlab
matlabTime = pgmatlab.utils.millisToDateNum(milliseconds);
```

## Database Functions

To use the functions in +db you will need to import that folder in every
function that uses this library
```matlab
import pgmatlab.db.*
```

This folder contains an ad-hoc set of database functions written to support our own research. They 
are not directly associated with reading binary files, but can be a useful companion to 
the binary file functions. 

### Getting a database connection

If you're using the PAMGuard sqlite database, Matlab provide a built in function to open sqlite 
database files
```matlab
conn = sqlite(dbfile,mode)
```
However, we've found that queries using connections from the sqlite function fail when any columms
contain null data. Therefore, to read data from a PAMGuard database, we recommend using our own
function
```matlab
import pgmatlab.db.*
conn = sqlitedatabase(dbfile)
```
which uses a different library that supports null data. 

**HOWEVER !!!**

We've also found that the the sqlite function is slightly better at writing data than 
sqlitedatabase. In particular, when writing TIMESTAMPS to a databsae, sqlitedatabase seems
to convert times to long integer times in milliseconds, whereas a database opened with the sqlite
function will write them correctly in a human readable date format. 

So yes: Use sqlitedatabase to read from a PAMGuard database, and sqlite to write to one. 

### Database Timestamp conversion

Timestamps are usually returned in a String or char array format. Use the dbdate2datenum function
to convert these data to Matlab dates

```matlab
import pgmatlab.utils.*
import pgmatlab.db.*
dbFile = './mydata/somedatabse.sqlite3';
conn = sqlitedatabase(dbFile);
data = conn.fetch('SELECT * FROM Sometableorother');
matlabDates = dbdate2datenum(data.UTC);
```

Although Matlab now supports a more advanced date handling functions using datetime arrays, 
we've found that the performance of these is poor and are currently sticking with the simple 
numeric dates, which are the number of days that have elapsed since '00-Jan-0000'.


## Compatibility

- Compatible with PAMGuard v2.00.15 and later
- Requires MATLAB R2016b or later
- Supports Windows, macOS, and Linux

## Contributing

Contributions are welcome! See [contributing.md](contributing.md) for development guidelines, including:

- How to set up the development environment
- Testing procedures
- How to add support for new PAMGuard modules
- Pull request guidelines

## License

See [LICENSE](LICENSE) file for details.

## Citation

If you use PAMGuardMatlab in your research, please cite:

```
PAMGuardMatlab (2024). Zenodo. DOI: 10.5281/zenodo.16979862
```