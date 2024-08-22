function [k, best, tune_time] = GeneticAlgorithmPIDTuner(layout_model, lb, ub, no_var, DriveCycle)
%% This function tunes the PID controller in the simulink layout model for a given drive cycle using the Genetic algorithm.
% Arguments:
%   - layout_model: a Simulink model containing the powertrain layout
%   - lb & ub: Lower and upper bounds for the output of Genetic Algorithm.
%   - no_var: Number of gains for the PID controller. 1, 2, 3 mean only P, PI and PID controller respectively.
%   - DriveCycle: Drive cycle data for the model and tuning.
% Returns:
%   - k: Tuned set of PID gains
%   - best: Cost function value on tuned set of gains
%   - tune_time: Time taken for tuning in seconds

% Measure the current time before running the simulation
start_tune_time = tic;

% Set the stop time as 30 seconds after the first non-zero value
index = find(DriveCycle(:,2) ~= 0, 1);
tend = num2str(30 + DriveCycle(index,1));
set_param(layout_model, 'StopTime', tend);

% Set the gain variables

driver_block = find_system(layout_model, 'Name', 'DRIVER');
if no_var == 1
   set_param(driver_block{1}, 'drive_cycle', 'DriveCycle', 'K_p', 'k(1)', 'K_i', '0', 'K_d', '0');
elseif no_var == 2 
   set_param(driver_block{1}, 'drive_cycle', 'DriveCycle', 'K_p', 'k(1)', 'K_i', 'k(2)', 'K_d', '0');
else
   set_param(driver_block{1}, 'drive_cycle', 'DriveCycle', 'K_p', 'k(1)', 'K_i', 'k(2)', 'K_d', 'k(3)');
end 

% GA parameters
ga_opt = optimoptions('ga', 'Display', 'off', 'Generations', 3, 'PopulationSize', 5); % , 'PlotFcns', @gaplotbestf
obj_fn = @(k) powertrain_sim(k);

% GA Command
[k, best] = ga((obj_fn),no_var,[],[],[],[],lb,ub,[],ga_opt);

% Measure the simulation time
tune_time = toc(start_tune_time);

end 