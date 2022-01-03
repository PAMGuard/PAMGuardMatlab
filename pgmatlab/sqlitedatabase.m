function con = sqlitedatabase(fn)
% function con = sqlitedatabase(fn)
% Directly open a SQLite database for use in Matlab.
% fn is an SQLite database file.
%
% to use this function you will need to first download the sqlite-jdbc
% interface version sqlite-jdbc-3.36.0.jar or later. This is currently
% available from https://github.com/xerial/sqlite-jdbc/releases.
% You wil then need to add the jar file to your Matlab Java class path
% or put it in a folder somewhere in your 'normal' Matlab path and
% it will be loaded dynamically as needed.

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
    driverClassPath = 'sqlite-jdbc-3.36.0.jar';
    jarFile = which(driverClassPath);
    javaaddpath(jarFile);
end

% now open the database.
con = database('','','',driver, [protocol fn]);