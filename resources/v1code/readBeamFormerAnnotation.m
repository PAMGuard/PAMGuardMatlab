function data = readBeamFormerAnnotation(fid, code, length, fileInfo, annotationVersion)
data.hydrophones = fread(fid, 1, 'uint32');
data.arrayType = fread(fid, 1, 'int16');
data.localisationContent = fread( fid, 1, 'uint32');
data.nAngles = fread(fid, 1, 'int16');
data.angles = fread(fid, data.nAngles, 'float32');