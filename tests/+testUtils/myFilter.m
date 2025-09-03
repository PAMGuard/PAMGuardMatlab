function selState = myFilter(data)
    % remove all data where type ~= 0
    if data.UID == 5000004
        selState = 0; % skip
    elseif data.UID >= 5000005
        selState = 2; % stop
    else
        selState = 1; % keep
    end
end