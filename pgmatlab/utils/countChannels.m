function nC = countChannels(channelMap)
% function nC = countChannels(channelMap)
% count the numebr of set bits in the channel map

%this function is called alot but many times folk will be anlalysing one
%channel data. This speeds up one channel a lot 
if channelMap==1
    nC=1; 
    return; 
end

nC = 0;
j = 1;
for i = 1:32
    if (bitand(channelMap, j))
        nC = nC + 1;
    end
    j = j * 2;
end