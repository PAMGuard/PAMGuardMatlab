# Contributing Guidelines

PAMGuardMatlab is an open-source project. Whilst out license does not require it, we welcome you to contribute any changes you make back to the original repository.

## Getting Started

If you're planning on making contributions to PAMGuardMatlab, we highly recommend that you fork the repository, and then clone it into your machine. In the MATLAB editor, on the left sidebar, click on the 'Project' button then select [pgmatlab.prj](pgmatlab.prj) in the root of your cloned repository. This will automatically set-up the development environment, including the MATLAB path.

## Testing

There is a comprehensive testing suite located in the [tests](tests) folder. To run these tests, run the following commands.

```commandline
cd tests;
runtests;
```

If you add new functionality to PAMGuardMatlab, please ensure you write appropriate unit tests in the testing suite. 

> If you find that the changes you have made are failing existing tests (due to an existing bug in the program or the testing suite), you are welcome to change the testing suite.

## Making a Pull Request

Once you are satisfied with your tested changes, you should make a pull request, linking an issue and with a detailed commit history (if there is one), changelog, and details and any new tests written. 

The GitHub repository will automatically run the unit tests in MacOS, Linux, and Windows - and you can see this by viewing your pull request.

## Creating a New Release

Stable code is maintained through new releases. This allows users to download a lightweight copy of the code without development tools such as tests.

Upon the creation of a release, the following CI action is executed (allow 30-60 seconds for this to complete):

- The user-facing code (README.md, LICENCE, pgmatlab/*) is put in an archive and attached to the release.

Releases should be semantically named and tagged like so. These tags are dynamically inserted in the tarball and wheel uploaded to PyPI.

- V1.2.3
  - Tag: v1.2.3
- V1.2.3 Beta 1
  - Tag: v1.2.3-b1
- V1.2.3 Alpha 1
  - Tag: v1.2.3-a1

## Structure

All the source code is found in the [pgmatlab/+pgmatlab](pgmatlab/+pgmatlab/) folder.

Folders use the plus (+) prefix to be treated as a 'package' (where [+pgmatlab](pgmatlab/+pgmatlab/) is the root). By adding [pgmatlab/](pgmatlab/) only the namespace `pgmatlab` is added to the MATLAB path. All classes and functions are accessible through sub-packages, such as: `pgmatlab.utils.millisToDateNum()`. We have temporarily kept three legacy entry points in the root source code folder to allow existing users to continue using the updated code.

PAMGuardMatlab has three main sub-packages:

1. [+core](pgmatlab/+pgmatlab/+core/): contains classes for reading chunks from data files.

2. [+db](pgmatlab/+pgmatlab/+db/): contains functions for interacting with the database (legacy).

3. [+utils](pgmatlab/+pgmatlab/+utils/): contains functions
for utilities used by the rest of the library.

## Adding New Modules

The object-oriented structure of PAMGuardMatlab allows you to easily create new modules by extending the base classes. This section provides templates and instructions for creating new module types.

### Creating a New Module Class

To create a new module, you need to extend the `StandardModule` class and implement the required abstract methods.

#### Template for a New Module

Create a new file in `pgmatlab/+pgmatlab/+core/+modules/` with the following template:

```matlab
classdef YourModuleName < pgmatlab.core.standard.StandardModule
    properties (Access = public)
        objectType = 'Your Object Type'; % Set this to match PAMGuard's object type
    end
    
    methods
        function obj = YourModuleName()
            % Constructor - set custom header/footer classes if needed
            obj.header = @pgmatlab.core.standard.StandardModuleHeader;
            obj.footer = @pgmatlab.core.standard.StandardModuleFooter;
            obj.background = -1; % Set to a background class if needed
        end
        
        function [data, selState] = readImpl(obj, fid, data, fileInfo, length, identifier, selState)
            % Read module-specific data from the binary file
            % This is where you implement the actual data reading logic
            
            % Example: Read some custom fields
            data.customField1 = fread(fid, 1, 'int32');
            data.customField2 = fread(fid, 1, 'double');
            
            % Additional processing can be done here
            
            % Return selState (1 = keep, 0 = skip, 2 = stop if sorted)
            selState = 1;
        end
        
        function [data, selState] = readBackgroundImpl(obj, fid, data, fileInfo, length, identifier, selState)
            % Optional: Implement background data reading if your module has background data
            % Leave empty if no background data
        end
    end
end
```

#### Creating Custom Header Classes

If your module requires a custom header format, create a class extending `StandardModuleHeader`:

```matlab
classdef YourModuleHeader < pgmatlab.core.standard.StandardModuleHeader
    methods
        function data = readImpl(obj, fid, data, fileInfo, length, identifier)
            % Call parent implementation first
            data = readImpl@pgmatlab.core.standard.StandardModuleHeader(obj, fid, data, fileInfo, length, identifier);
            
            % Read custom header fields
            data.customHeaderField = fread(fid, 1, 'int32');
            
            % Process additional header data as needed
        end
    end
end
```

#### Creating Custom Footer Classes

Similarly, for custom footers, extend `StandardModuleFooter`:

```matlab
classdef YourModuleFooter < pgmatlab.core.standard.StandardModuleFooter
    methods
        function data = readImpl(obj, fid, data, fileInfo, length, identifier)
            % Call parent implementation first
            data = readImpl@pgmatlab.core.standard.StandardModuleFooter(obj, fid, data, fileInfo, length, identifier);
            
            % Read custom footer fields
            data.customFooterField = fread(fid, 1, 'int32');
        end
    end
end
```

#### Creating Custom Background Classes

For modules with background data, extend `StandardBackground`:

```matlab
classdef YourModuleBackground < pgmatlab.core.standard.StandardBackground
    properties (Access = public)
        objectType = 'Your Background Object Type';
    end
    
    methods
        function [data, selState] = readImpl(obj, fid, data, fileInfo, length, identifier, selState)
            % Read background-specific data
            data.backgroundField1 = fread(fid, 1, 'double');
            data.backgroundField2 = fread(fid, [1, 10], 'int16');
            
            selState = 1;
        end
    end
end
```

### Registering Your Module

After creating your module class, you need to register it in the main loading function. Add your module to the switch statement in `loadPamguardBinaryFile.m`:

```matlab
% In the file header case (-1) switch statement:
case 'Your Module Type'
    switch fileInfo.fileHeader.streamName
        case 'Your Stream Name'
            moduleObj = pgmatlab.core.modules.YourModuleName();
        % Add additional stream cases if needed
    end
```

The module type should match the string used by PAMGuard's module (found in the Java code), and the stream name should match the data stream name used by your PAMGuard module.

### Testing Your Module

1. Create test data using your PAMGuard module
2. Add test cases to the appropriate test file in the `tests/` folder
3. Run the tests to ensure your module loads data correctly:

```matlab
cd tests;
runtests('YourModuleTest');
```

### Example: Complete Module Implementation

Here's a complete example of a simple module:

```matlab
classdef ExampleModule < pgmatlab.core.standard.StandardModule
    properties (Access = public)
        objectType = 'Example Detection';
    end
    
    methods
        function obj = ExampleModule()
            obj.header = @pgmatlab.core.standard.StandardModuleHeader;
            obj.footer = @pgmatlab.core.standard.StandardModuleFooter;
            obj.background = -1;
        end
        
        function [data, selState] = readImpl(obj, fid, data, fileInfo, length, identifier, selState)
            % Read example-specific fields
            data.detectionType = fread(fid, 1, 'int32');
            data.confidence = fread(fid, 1, 'double');
            data.frequency = fread(fid, 1, 'double');
            
            % Validate data
            if data.confidence < 0 || data.confidence > 1
                warning('Invalid confidence value: %f', data.confidence);
            end
            
            selState = 1;
        end
    end
end
```

Then register it in `loadPamguardBinaryFile.m`:

```matlab
case 'Example Detector'
    switch fileInfo.fileHeader.streamName
        case 'Example Detections'
            moduleObj = pgmatlab.core.modules.ExampleModule();
    end
```