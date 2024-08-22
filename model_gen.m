function layout_model = model_gen(layout, layout_model)
%function layout_model = model_gen(layout, layout_conn_type, layout_model)
%% This function generates a block layout in Simulink based on the provided sequence
% layout, adds controller and forms control loops.
% Arguments:
%   - layout: A sequence of components
%   - layout_model: Simulink model (so that any leftover saved file from previous iterations can be deleted)

% Returns: 
%   - layout_model: a Simulink model containing the desired layout

% Initialize variables
counts = zeros(size(layout));
pos_0 = [50, 50, 200, 150]; 
h_previous = [];
layout_model = 'Powertrain_Layout';
spacing = 250;

% Array for storing transmission block names
tr_block_names = cell(1, sum(strcmp(layout, 'TR')));
tbn = 0;

% Generate layout's connection status array
%num_sublists = numel(layout_conn_type);
%max_sublist_length = max(cellfun(@numel, layout_conn_type));
%conn_status = zeros(num_sublists, max_sublist_length);

bdclose(layout_model); % Remove any previous model from memory
new_system(layout_model); % Create new Simulink model in memory

% Set the solver to fixed step with step size 0.001
set_param(layout_model, 'SolverType', 'Fixed-step');
set_param(layout_model, 'FixedStep', '0.001');
set_param(layout_model, 'AlgebraicLoopMsg', 'none');

for j = 1:length(layout)
    % Give the current block a unique name 
    counts(j) = sum(strcmp(layout{j}, layout(1:j-1)));
    current_block_name = layout{j};
    if counts(j) > 0
        current_block_name = [layout{j}, num2str(counts(j) + 1)];
    end
    
    % Calculate block position
    pos = pos_0 + [(j - 1) * spacing, 0, (j - 1) * spacing, 0]; 
    
    % Add block to model
    switch layout{j}     
        case 'BAT'
            block_type = 'Battery';
        case 'FT'
            block_type = 'Fuel Tank';
        case 'ICE'
            block_type = 'IC Engine';
            ice_block_name = current_block_name;
        case 'MOT'
            block_type = 'Motor';
            mot_block_name = current_block_name;
        case 'GEN'
            block_type = 'Generator-Battery';
            gen_block_name = current_block_name;
        case 'GB'
            block_type = 'Gearbox';
        case 'TR'
            block_type = 'Transmission';
            tbn = tbn + 1;
            tr_block_names{tbn} = current_block_name;
        case 'VEH'
            block_type = 'Vehicle';
            veh_block_name = current_block_name;
            
    end
    add_block(['Powertrain_Library_GenAI/', block_type], [layout_model, '/', current_block_name], 'Position', pos); 
    % Check port compatibility & status for connection
    if isempty(h_previous)
        h_previous = get_param([layout_model, '/', current_block_name], 'PortHandles');
    else 
        h_current = get_param([layout_model, '/', current_block_name], 'PortHandles');
        add_line(layout_model, h_current.LConn(1), h_previous.RConn(1), 'autorouting', 'on')
        % conected = false; 
        % for k = 1:length(layout_conn_type{j-1})
        %     if conected
        %         break; % Break out of outer loop
        %     end
        %     for l = 1:length(layout_conn_type{j})
        %         if strcmp(layout_conn_type{j-1}{k}, layout_conn_type{j}{l}) && conn_status(j-1,k) == 0
        %             % connect
        %             first_port = h_previous.LConn(k);
        %             second_port = h_current.LConn(l);
        %             conn_status(j,l) = 1;
        % 
        %             % Form a connection
        %             add_line(layout_model, second_port, first_port, 'autorouting', 'on')
        %             conected = true;
        %             break; % Break out of inner loop  
        %         end
        %     end 
        % end 
        h_previous = get_param([layout_model, '/', current_block_name], 'PortHandles');
    end 
end 

% Add driver / controller block
pos_d = pos_0 + [length(layout) * spacing, 0, length(layout) * spacing, 0];
if ismember('GEN', layout)
    add_block('Powertrain_Library_GenAI/Driver', [layout_model, '/', 'DRIVER'], 'Position', pos_d, 'series_hybrid_mode', '1');
else
    add_block('Powertrain_Library_GenAI/Driver', [layout_model, '/', 'DRIVER'], 'Position', pos_d, 'series_hybrid_mode', '0');
end 

h_driver = get_param([layout_model, '/DRIVER'], 'PortHandles');

% Form control loops
if ismember('VEH', layout)
    h_veh = get_param([layout_model, '/', veh_block_name], 'PortHandles');
    add_line(layout_model, h_veh.Outport(1), h_driver.Inport(1), 'autorouting', 'on');
end 
if ismember('ICE', layout)
    h_ice = get_param([layout_model, '/', ice_block_name], 'PortHandles');
    add_line(layout_model, h_driver.Outport(1), h_ice.Inport(1), 'autorouting', 'on');
end 
if ismember('MOT', layout)
    h_mot = get_param([layout_model, '/', mot_block_name], 'PortHandles');
    add_line(layout_model, h_driver.Outport(2), h_mot.Inport(1), 'autorouting', 'on');
end
if ismember('GEN', layout)
    h_gen = get_param([layout_model, '/', gen_block_name], 'PortHandles');
    add_line(layout_model, h_gen.Outport(1), h_driver.Inport(2), 'autorouting', 'on');
end
if ismember('TR', layout)
    for tbn2 = 1:tbn
        h_tr = get_param([layout_model, '/', tr_block_names{tbn2}], 'PortHandles');
        add_line(layout_model, h_veh.Outport(1), h_tr.Inport(1), 'autorouting', 'on');
    end 
end 

set_param(layout_model, 'ZoomFactor', 'FitToView');
end 