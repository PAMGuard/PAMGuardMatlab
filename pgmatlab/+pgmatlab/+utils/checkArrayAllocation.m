% Check the array allocation. This gets called every time data are read and
% will extend the array by approximately the sqrt of the arrays own length
% if required. Preallocation acheived by sticking a sample object at a high
% data index so that array up to that point gets filled with nulls.
function array = checkArrayAllocation(array, reqLength, sampleObject)
if isempty(array)
    currentLength = 0;
    clear array;
else
    currentLength = numel(array);
end
if (currentLength >= reqLength)
    return;
end
allocStep = round(sqrt(reqLength));
allocStep = max(10, min(allocStep, 10000));
array(reqLength + allocStep) = sampleObject;
return;
end
