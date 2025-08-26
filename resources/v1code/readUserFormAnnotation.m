function [formdata] = readDLAnnotation(fid, anId, anLength, fileInfo, anVersion)
%READDLANNOTAION - read a user form annotation
txtLen = anLength-length(anId)-2-2;
formdata = fread(fid, txtLen,'char')';
formdata = char(formdata);
end