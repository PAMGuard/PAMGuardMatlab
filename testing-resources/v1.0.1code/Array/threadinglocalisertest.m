dbName = 'C:\OBSERVE_SURVEY\Survey#2\OBSERVE#2Offline.sqlite3';
phoneLength = 100; % hydrophone length in metres. 
date = datenum(2015,8,28,12,0,0); % the date we want a position for
% read in data for a few minutes either side ...
oneSecond = 1/(24*3600);
% test for several positions, seconds apart ...
date = date + [0:20]*oneSecond;

% get gps data from 10 minutes before to one minute after our first and
% last times. 
dateRange = [min(date)-oneSecond*600 max(date)+oneSecond*60];
% read in some gps data
qStr = sprintf('SELECT * FROM gpsData WHERE UTC BETWEEN %s AND %s AND Id>0 ORDER BY UTC', ...
    datenum2dbdate(dateRange(1),''''), datenum2dbdate(dateRange(2),''''));
% qStr = 'SELECT * FROM gpsData WHERE Id>0 ORDER BY UTC'
setdbprefs('datareturnformat', 'structure');
con = sqlitedatabase(dbName);
q  =exec(con, qStr);
q = fetch(q);
gpsData = q.Data;
close(con);


[hPos, shipPos, shipInd, arrayInd] = threadinglocaliser(gpsData, phoneLength, date);

figure(1)
clf
plot(gpsData.Longitude, gpsData.Latitude)
axis equal
hold on
plot(shipPos.Longitude, shipPos.Latitude, 'ob');
plot(hPos.Longitude, hPos.Latitude, 'or');
% set(gca, 'ylim', minmax(hPos.Latitude))

figure(2)
clf
% plot in metres
refLat = shipPos.Latitude(1);
refLong = shipPos.Longitude(1);
[~, x, y] = latlongdistance(refLat, refLong, gpsData.Latitude, gpsData.Longitude);
plot(x, y, '-k')
hold on
plot(x, y, '.')
axis equal;
[~, x, y] = latlongdistance(refLat, refLong, shipPos.Latitude, shipPos.Longitude);
plot(x, y, 'ob')
[~, x, y] = latlongdistance(refLat, refLong,  hPos.Latitude, hPos.Longitude);
plot(x, y, 'or')
% now draw on all the headings of all the hydrophone points to see if 
% they are realistic or not
head = hPos.Heading;
hLen = 2;
for i = 1:numel(head)
    dx = sind(head(i))*hLen;
    dy = cosd(head(i))*hLen;
    line(x(i)+[0 dx], y(i)+[0 dy], 'color', 'r'); 
end

% set(gca, 'ylim', minmax(y) + [-2 2])