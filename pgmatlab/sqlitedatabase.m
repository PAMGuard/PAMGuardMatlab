function con = sqlitedatabase(fn, create)
% function con = sqlitedatabase(fn)
% Directly open a SQLite database for use in Matlab.
%   fn: the path (filename) of a SQLite database file.
%   create: if true, create an empty database. If false, return null
%
%
% to use this function you will need to first download the sqlite-jdbc
% interface version sqlite-jdbc-3.36.0.jar or later. This is currently
% available from https://github.com/xerial/sqlite-jdbc/releases.
% You wil then need to add the jar file to your Matlab Java class path
% or put it in a folder somewhere in your 'normal' Matlab path and
% it will be loaded dynamically as needed.
% persistent waswarned;
% if isempty(waswarned)
%     waswarned = 1;
%     disp(' ************************ OBSOLETE FUNCTION ************************');
%     disp(' * You''re probably better off using the in built sqlite function   *' );
%     disp(' * to open sqlite database files. This one is OK for reading, but  *');
%     disp(' * does not write timestamps to the database in the correct format *');
%     disp(' *******************************************************************');
% end
if nargin == 0
    error('You must specify a database file name');
end
if nargin == 1
    create = false;
end
if (~create)
    % check the file exists
    dd = dir(fn);
    if (numel(dd) == 0) 
        error('You must specify a path to an existing databse or set create to true to make a blank database');
    end
end

% declare the driver and protocl needed to open the database.
driver = 'org.sqlite.JDBC';
protocol = 'jdbc:sqlite:';

% these lines can be removed if the driver class is already
% added permanently to your class path.
% need to see if the class is available, in which case
% we won't need to load it.
% javarmpath(driver)
try
    javaObjectEDT(driver)
catch
    % if an exception was thrown, try to load the library.
    % this will always happen the first time the function is called. 
    % driverClassPath = 'sqlite-jdbc-3.36.0.jar';
    % 3.45.3.0 is the current PAMGuard version as of V2.02.17, August 2025
    driverClassPath = 'sqlite-jdbc-3.45.3.0.jar';
    jarFile = which(driverClassPath);
    javaaddpath(jarFile);
end

% check dbName is char, not string
if isstring(fn)
    fn = char(fn);
end
% now open the database.
con = database('','','',driver, [protocol fn]);