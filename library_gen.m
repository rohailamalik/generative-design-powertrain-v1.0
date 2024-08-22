function library = library_gen(library_name)
%% This function extracts attributes of masked component blocks from the simulink library.
% Arguments: Library file name
% Returns: A structure with the following fields:
%   - library: names of components
%   - conn_type: connection energy types for all components
%   - conn_dir: connection energy flow directions for all components
%   - actuators: names of actuators
%   - loads: names of loads

% Find all blocks in the library
load_system(library_name);
allBlocks = find_system(library_name, 'Type', 'Block');

% Initialize cell array to store attribute vectors
attr_vector = cell(length(allBlocks), 1);

% Get parameters for all blocks
for i = 1:length(allBlocks)
    attr_vector{i} = eval(get_param(allBlocks{i}, 'attribute_vector'));
end

% Filter out controllers and categorize the remaining components
non_controller_indices = ~cellfun(@(x) strcmp(x{1}, 'CONTROLLER'), attr_vector);
filtered_attr_vector = attr_vector(non_controller_indices);

% Populate the library_info structure
library.library = cellfun(@(x) x{2}, filtered_attr_vector, 'UniformOutput', false);
library.conn_type = cellfun(@(x) x{4}, filtered_attr_vector, 'UniformOutput', false);
library.conn_dir = cellfun(@(x) x{5}, filtered_attr_vector, 'UniformOutput', false);

library.actuators = library.library(cellfun(@(x) strcmp(x{1}, 'ACTUATOR'), filtered_attr_vector));
library.actuators_conn_type = library.conn_type(cellfun(@(x) strcmp(x{1}, 'ACTUATOR'), filtered_attr_vector));
library.actuators_conn_dir = library.conn_dir(cellfun(@(x) strcmp(x{1}, 'ACTUATOR'), filtered_attr_vector));

library.loads = library.library(cellfun(@(x) strcmp(x{1}, 'LOAD'), filtered_attr_vector));
library.loads_conn_type = library.conn_type(cellfun(@(x) strcmp(x{1}, 'LOAD'), filtered_attr_vector));
library.loads_conn_dir = library.conn_dir(cellfun(@(x) strcmp(x{1}, 'LOAD'), filtered_attr_vector));

end
