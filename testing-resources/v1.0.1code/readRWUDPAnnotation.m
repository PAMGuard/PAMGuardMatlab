function [data] = readRWUDPAnnotation(fid, anId, anLength, fileInfo, anVersion)
%Read RW UDP classification
data.label = readJavaUTFString(fid);
data.method = readJavaUTFString(fid);
data.score = fread(fid, 1, 'float32');



end

