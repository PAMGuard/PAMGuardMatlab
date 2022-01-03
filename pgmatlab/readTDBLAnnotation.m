function tdbl = readTDBLAnnotation(fid, anId, anLength, fileInfo, anVersion)
nAngles = fread(fid, 1, 'int16');
tdbl.angles = fread(fid, nAngles, 'float32');
nErrors = fread(fid, 1, 'int16');
tdbl.angleErrors = fread(fid, nErrors, 'float32');
