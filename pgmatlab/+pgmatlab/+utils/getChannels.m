function [ nC ] = getChannels( channelMap )
% GETCHANNELS - returns an array of channel numbers (starting at 0) for a
% channel bitmap. 
nC =[];
j = 1;
for i = 1:32
    if (bitand(channelMap, j))
        nC = [nC ,i-1];
    end
    j = j * 2;
end

if (isempty(nC))
    nC=[0];
end
end

