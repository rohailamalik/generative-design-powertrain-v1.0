function results = GenDesignIteration(library, DriveCycle, parameters)

% Generating layout in the form of a sequence 
layout = layout_gen(library);

% Generating layout model in Simulink, with blocks and connections
layout_model = model_gen(layout.layout);

% Assigning parameters to the blocks
layout_model = parametrizer(layout_model, parameters);

% PID Controller tuning
no_var = 1;
lb = 0;
ub = 500;
[k, best, tuning_time] = GeneticAlgorithmPIDTuner(layout_model, lb, ub, no_var, DriveCycle);

% Running simulation on whole drivecycle. Units in the returning variables: N/A, Wh, Wh/km, Euros, tons of CO2
[results.MAE, results.E_total, results.E_specific, results.cost, results.emissions, results.fig] = Powertrain_tester(layout_model, DriveCycle);
results.layout = layout.layout;
results.layout_model = layout_model;
end 