function [arrayPos, shipPos, shipIndex, arrayIndex] = threadinglocaliser(gpsData, arrayLength, time)
% function arrayPos = threadinglocaliser(gpsData, arrayLength, time)
%
% calculate the likely array position based on a set of vessel gps datas
% read in from the database, a distance astern of the gps receiver and a
% time. Return will be a structure containing the latitude, longitude and
% heading of the array at that moment in time.
if nargin == 0
    % convenience fude to make it call the test function without me 
    % having to keep flipping to a different editor tab
    threadinglocalisertest()
    return
end
global gpsDate
arrayPos = [];
shipPos = [];
arrayIndex = [];
shipIndex = [];
if numel(time) > 1
   % will have to call this function individually for every different time
   % for it to work. 
   for i = 1:numel(time)
       [aPos, sPos, sIndex, aIndex] = threadinglocaliser(gpsData, arrayLength, time(i));
       arrayPos = catstruct(arrayPos, aPos);
       shipPos = catstruct(shipPos, sPos);
       arrayIndex = [arrayIndex aIndex];
       shipIndex = [shipIndex, sIndex];
   end
    return
end
% need to extract the times from the gpsData
gpsDate = dbdate2datenum(gpsData.UTC);
% now find the GPS position closest in time to our current position
[shipTime shipIndex] = min(abs(time-gpsDate));
shipTime = gpsDate(shipIndex);
% fprintf('wanted %s, ship gps %s\n', datestr(time, 31), datestr(shipTime, 31));
% really want the Gps before, so we really know where we are
if (shipTime > time)
    shipIndex = shipIndex-1;
    shipTime = gpsDate(shipIndex);
end
nextShipTime = gpsDate(shipIndex+1); % time of the gps point after the one we want.
shipPos = interpolateGpsTime(gpsData, shipIndex, shipIndex+1, time);
% now work backwards along the array for the appropriate distance.
distanceBack = arrayLength - latlongdistance(shipPos.Latitude, shipPos.Longitude, ...
    gpsData.Latitude(shipIndex), gpsData.Longitude(shipIndex));
arrayIndex = shipIndex;
d = 0;
while distanceBack > 0
    arrayIndex = arrayIndex - 1;
    if (arrayIndex <= 0)
        break
    end
    d = latlongdistance(gpsData.Latitude(arrayIndex+1), gpsData.Longitude(arrayIndex+1),...
        gpsData.Latitude(arrayIndex), gpsData.Longitude(arrayIndex));
    if (d > distanceBack)
        break;
    end
    distanceBack = distanceBack-d;
end
    arrayIndex = arrayIndex + 0;
% should now have pIndex pointing at the gps data BEFORE where the
% hydrophone is so do a final interpolation based on distance.
% distance back should still be >= 0
if (d == 0)
    x1 = 1;
    x2 = 0;
else
    x2 = distanceBack/d;
    x1 = 1-x2;
end
arrayPos = interpolateGps(gpsData, arrayIndex, arrayIndex+1, x1, x2);

end


function g = interpolateGpsTime(gpsData, ind1, ind2, time)
global gpsDate
% interpolate between two gps points based on time. 
% assume that ind1 and ind2 refer to points before and after the
% time we want.
dt1 = time-gpsDate(ind1);
dt2 = gpsDate(ind2)-time;
if (dt1+dt2 == 0)
    x1 = 1;
    x2 = 0;
else
    x1 = dt2/(dt1+dt2);
    x2 = dt1/(dt1+dt2);
end
g = interpolateGps(gpsData, ind1, ind1, x1, x2);
end
function g = interpolateGps(gpsData, ind1, ind2, x1, x2)
% interpolate between gps points based on x1 = fraction of first to use
% and x2 = fraction of second to use. x1+x2 = 1 !
g.Latitude = gpsData.Latitude(ind1)*x1+gpsData.Latitude(ind2)*x2;
g.Longitude = gpsData.Longitude(ind1)*x1+gpsData.Longitude(ind2)*x2;
g.Speed = gpsData.Speed(ind1)*x1 + gpsData.Speed(ind2)*x2;
fNames = fields(gpsData);
if sum(strcmp(fNames,'Heading'))
    g.Heading = interpolateAngle(gpsData.Heading(ind1), gpsData.Heading(ind2), x1, x2);
end
if sum(strcmp(fNames,'TrueHeading'))
    g.TrueHeading = interpolateAngle(gpsData.TrueHeading(ind1), gpsData.TrueHeading(ind2), x1, x2);
end
if sum(strcmp(fNames,'MagneticHeading'))
    g.MagneticHeading = interpolateAngle(gpsData.MagneticHeading(ind1), gpsData.MagneticHeading(ind2), x1, x2);
end

end

function h = interpolateAngle(head1, head2, x1, x2)
% interpolate between two angles, noting that they may be either side of
% zero, i.e. the mean angle of 359 and 1 is 0, not 180 !
x = sind(head1)*x1+sind(head2)*x2;
y = cosd(head1)*x1+cosd(head2)*x2;
h = atan2d(x,y);
if h < 0
    h = h + 360;
end
end