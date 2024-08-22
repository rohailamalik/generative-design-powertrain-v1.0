function layout_model = parametrizer(layout_model, parameters)
%% This function assigns parameters to the blocks in the Simulink model from provided sets.
% Arguments: 
%   - layout_model: Simulink model containing the desired layout
%   - Parameters: Multiple sets of parameters for each component block.
% Returns
%   - layout_model: Simulink model containing the desired layout and the assigned parameters

% Get all elements in the model
blocks = find_system(layout_model, 'Type', 'Block');

% Loop through each block and assign random parameters from provided values
for i = 1:length(blocks)
    elementType = get_param(blocks{i}, 'ReferenceBlock');
    
    if strcmp(elementType, 'Powertrain_Library_GenAI/Battery')
        BAT_par_sim = parameters.BAT_par(randi(size(parameters.BAT_par, 1)), :);
        BAT_par_sim = arrayfun(@num2str, BAT_par_sim, 'UniformOutput', false);
        set_param(blocks{i}, 'V_bat_nom', BAT_par_sim{1}, 'mAh_bat_rated', BAT_par_sim{2}, 'cost', BAT_par_sim{3}, 'base_emissions', BAT_par_sim{4});
    
    elseif strcmp(elementType, 'Powertrain_Library_GenAI/Generator-Battery')
        GEN_par_sim = parameters.GEN_par(randi(size(parameters.GEN_par, 1)), :);
        GEN_par_sim = arrayfun(@num2str, GEN_par_sim, 'UniformOutput', false);
        set_param(blocks{i}, 'V_bat_nom', GEN_par_sim{1}, 'mAh_bat_rated', GEN_par_sim{2}, 'cost', GEN_par_sim{3}, 'base_emissions', GEN_par_sim{4});    
    
    elseif strcmp(elementType, 'Powertrain_Library_GenAI/Gearbox')
        GB_par_sim = parameters.GB_par(randi(size(parameters.GB_par, 1)), :);
        GB_par_sim = arrayfun(@num2str, GB_par_sim, 'UniformOutput', false);
        set_param(blocks{i}, 'G', GB_par_sim{1}, 'cost', GB_par_sim{2}, 'base_emissions', GB_par_sim{3});

    % elseif strcmp(elementType, 'Powertrain_Library_GenAI/Transmission')
    %     TR_par_sim = parameters.TR_par(randi(size(parameters.TR_par, 1)), :);
    %     Shift_par_sim = parameters.Shift_par(randi(size(parameters.Shift_par, 1)), :);
    %     TR_par_sim = arrayfun(@num2str, TR_par_sim, 'UniformOutput', false);
    %     Shift_par_sim = arrayfun(@num2str, Shift_par_sim, 'UniformOutput', false);
    %     set_param(blocks{i}, 'Gs', TR_par_sim{1}, 'shift_thresholds', Shift_par_sim);
    
    elseif strcmp(elementType, 'Powertrain_Library_GenAI/IC Engine')
        ICE_par_sim = parameters.ICE_par(randi(size(parameters.ICE_par, 1)), :);
        ICE_par_sim = arrayfun(@num2str, ICE_par_sim, 'UniformOutput', false);
        set_param(blocks{i}, 'T_p', ICE_par_sim{1}, 'P_p', ICE_par_sim{2}, 'w_T', ICE_par_sim{3}, 'w_P', ICE_par_sim{4}, ...
            'w_ice_max', ICE_par_sim{5}, 'cost', ICE_par_sim{6}, 'base_emissions', ICE_par_sim{7});
    
    elseif strcmp(elementType, 'Powertrain_Library_GenAI/Motor')
        MOT_par_sim = parameters.MOT_par(randi(size(parameters.MOT_par, 1)), :);
        MOT_par_sim = arrayfun(@num2str, MOT_par_sim, 'UniformOutput', false);
        set_param(blocks{i}, 'T_mot_max', MOT_par_sim{1}, 'P_mot_max', MOT_par_sim{2}, 'cost', MOT_par_sim{3}, 'base_emissions', MOT_par_sim{4});
    
    elseif strcmp(elementType, 'Powertrain_Library_GenAI/Vehicle')
        Env_par_sim = parameters.Env_par(randi(size(parameters.Env_par, 1)), :);
        VEH_par_sim = parameters.VEH_par(randi(size(parameters.VEH_par, 1)), :);
        Env_par_sim = arrayfun(@num2str, Env_par_sim, 'UniformOutput', false);
        VEH_par_sim = arrayfun(@num2str, VEH_par_sim, 'UniformOutput', false);
        set_param(blocks{i}, 'm', VEH_par_sim{1}, 'r', VEH_par_sim{2}, 'A', VEH_par_sim{3}, 'C_D', VEH_par_sim{4}, ...
            'cost', VEH_par_sim{5}, 'base_emissions', VEH_par_sim{6}, ...
            'mu_rr', Env_par_sim{1}, 'rho', Env_par_sim{2}, 'g', Env_par_sim{3});
    
    end
end