function tma = readTMAnnotation(fid, anId, anLength, fileInfo, anVersion)
tma.model = readJavaUTFString(fid);
tma.nLocations = fread(fid, 1, 'int16');
tma.hydrophones = fread(fid, 1, 'uint32');
for i = 1:tma.nLocations
   loc.latitude = fread(fid, 1, 'float64'); 
   loc.longitude = fread(fid, 1, 'float64'); 
   loc.height = fread(fid, 1, 'float32');
   loc.error = readJavaUTFString(fid);
   tma.loc(i) = loc;
end

