function c = charArray(in)
    %pgmatlab.utils.CHARARRAY - convert a string to a byte array, or cell
    %   of strings to a cell array of char arrays. Can pass in a mix of
    %   strings and char arrays.
    %
    %   Example 1:
    %       >>> res = pgmatlab.utils.charArray({"v1", 'v2', {'v3', "v4"}};
    %       This produces {'v1', 'v2', {'v3', 'v4'}}
    %
    %   Example 2:
    %       >>> res = pgmatlab.utils.charArray([])
    %       This produces {}
    %
    %   Example 3:
    %       >>> res = pgmatlab.utils.charArray({})
    %       This produces {}
    %
    
    if (iscell(in))
        % Preallocate space for c
        c{numel(in)} = -1;
        for i = 1:numel(in)
            c{i} = pgmatlab.utils.charArray(in{i});
        end
        return;
    end
    c = char(in);
    return;
end