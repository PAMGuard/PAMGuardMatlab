function data = readBearingAnnotation(fid, code, length, fileInfo, annotationVersion)
data.algorithmName = readJavaUTFString(fid);
data.version = annotationVersion;
data.hydrophones = fread(fid, 1, 'uint32');
data.arrayType = fread(fid, 1, 'int16');
data.localisationContent = fread( fid, 1, 'uint32');
data.nAngles = fread(fid, 1, 'int16');
data.angles = fread(fid, data.nAngles, 'float32');
data.nErrors = fread(fid, 1, 'int16');
data.errors = fread(fid, data.nErrors, 'float32');
if (annotationVersion >= 2) 
    nAng = fread(fid, 1, 'int16');
    data.refAngles = fread(fid, nAng, 'float32')
end