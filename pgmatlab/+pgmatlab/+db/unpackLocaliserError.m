function [error, unpacked] = unpackLocaliserError(errorString)
% function error = unpackError(errorString)
% unpack an error string from the PAMGuard 3D localiser. These are in a
% json like format but without all the json headers.
if iscell(errorString)
    % handle multiple strings
    n = numel(errorString);
    for i = n:-1:1
        e = pgmatlab.db.unpackLocaliserError(errorString{i});
        if ~isempty(e)
            error(i) = e;
        else 
%             error(i) = 0;
        end
        
    end
else
    % call gets here for a single string. 
    try
        error = jsondecode(errorString);
    catch
        error = [];
    end
end

if nargout < 2
    return
end
% now further transofrm the errors into cartesian coordinates. 

% take the errors and try to get a meanish / total error out of them.
totErrors = zeros(1,numel(errorString))*NaN;
radialError = zeros(1,numel(errorString))*NaN;
xyError = zeros(1,numel(errorString))*NaN;
vError = zeros(1,numel(errorString))*NaN;
allEangles = zeros(3,numel(errorString))*NaN;
for i = 1:numel(error)
    e = error(i);
    eVal = e.ERRORS;
    if numel(e.ANGLES) == 3
        allEangles(:,i) = e.ANGLES;
    end
    if isempty(eVal)
        xyError(i) = NaN;
        radialError(i) = NaN;
        totErrors(i) = NaN;
        continue;
    end
    if numel(eVal) == 6
        et = 0;
        for ii = 1:3
            ei = sqrt(eVal(ii)*eVal(ii+3));
            et = et + ei^2;
        end
%         er = sqrt(eVal(1)*eVal(4));
        er = max(eVal([1 4]));
        %         er = eVal(1);
        et = sqrt(et);
    else
        et = sqrt(sum(eVal.^2));
        er = eVal(2);
    end
    xyError(i) = cos(e.ANGLES(2))*er;
    vError(i) = sin(e.ANGLES(2))*er;
    radialError(i) = er;
    totErrors(i) = et;
end
unpacked.xyError = xyError;
unpacked.radialError = radialError;
unpacked.totErrors = totErrors;