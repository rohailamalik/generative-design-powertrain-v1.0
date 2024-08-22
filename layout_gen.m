function layout = layout_gen(library)
%% This function generates a random powertrain layout in form of a sequence.
% This function always starts from a Vehicle block.
% Arguments:
% - library: A structure containing components, names of actuators and loads, and connection types.
% Returns:
% - layout: A random "linear" powertrain layout sequence with at least one load block and an actuator.

% Determining number of connections of each item
connections = cellfun(@numel, library.conn_type);
n = numel(library.library);

% Initialization
layout.layout = {'VEH'};
layout.layout_conn_type = {{'MECH'}};
layout.layout_conn_dir = {{'IN'}};
max_repeat = 01; % Maximum times a component is repeated in a layout (not necessarily consecutively)

while true % Looping for item placement   
    k = 1; % Leftmost element in sequence (i.e., current element being considered)
    conn_old = layout.layout_conn_dir{k}{1};
    while true % Looping for connection component 
        j = randi(n); % Random index
        %disp(library.library{j});

        if sum(ismember(layout.layout, library.library{j})) <= max_repeat - 1 
            % Check if left connection of new item is compatible with left one of old. If so, flip it and add it to left.
            conn_new = library.conn_dir{j}{1};
            if strcmp(library.conn_type{j}{1}, layout.layout_conn_type{k}{1})
                if direction_validity(conn_new, conn_old)
                    layout.layout_conn_dir = [{flip(library.conn_dir{j})}, layout.layout_conn_dir];
                    layout.layout_conn_type = [{flip(library.conn_type{j})}, layout.layout_conn_type];
                    layout.layout = [library.library{j}, layout.layout];
                    break;
                end 
            end 
            % Check if right connection of new item (if it has 2 connections) is compatible with left one of old. If so, add it to left.
            if length(library.conn_type{j}) == 2
                conn_new = library.conn_dir{j}{2};
                if strcmp(library.conn_type{j}{2}, layout.layout_conn_type{k}{1})  
                    if direction_validity(conn_new, conn_old)
                        layout.layout_conn_dir = [{library.conn_dir{j}}, layout.layout_conn_dir];
                        layout.layout_conn_type = [{library.conn_type{j}}, layout.layout_conn_type];
                        layout.layout = [library.library{j}, layout.layout];
                        break;
                    end 
                end 
            end 
        end 
    end % Loop otherwise, come up with new index
    if connections(j) == 1
        break; % Stop adding if the last added item has 1 connection
    end 
end

% Function used in the code above for determining if energy flow directions of ports are valid for a connection
function dir_valid = direction_validity(conn_new, conn_old)
    dir_valid = false;
    if strcmp(conn_new, 'DUAL') 
        dir_valid = true;
    elseif strcmp(conn_old, 'DUAL')
        dir_valid = true;
    elseif strcmp(conn_new, 'IN') && strcmp(conn_old, 'OUT')
        dir_valid = true;
    elseif strcmp(conn_new, 'OUT') && strcmp(conn_old, 'IN') 
        dir_valid = true;
    end 
end
end 