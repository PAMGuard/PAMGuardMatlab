% dir_to_search = './data/detectors';

dir_to_search = './data/';

files = dir(fullfile(dir_to_search, '**/*.pgdf'));
file_paths = fullfile({files.folder}, {files.name});

% Convert to a cell array of strings
file_paths_cell = cellfun(@(x) ['''', x, ''''], file_paths, 'UniformOutput', false);

% Join the cell array into a single string
file_paths_str = sprintf('%s, ', file_paths_cell{:});

% Remove the trailing comma and space
file_paths_str = file_paths_str(1:end-2);

% Print the result
fprintf('{%s};\n', file_paths_str);