function cost = powertrain_sim(k)
%% This function simulates a powertrain simulink model using a given value of PID gains and gives ITAE as output.
% Arguments:
%   - k: PID controller gains
% Returns:
%   - cost: Intigrated Time Absolute Error

%index = find(DriveCycle(:,2) ~= 0, 1);
%tend_tune = num2str(30 + DriveCycle(index,1));
assignin("base", "k", k);
simulation = sim("Powertrain_Layout", 'StopTime', '30');

time_steps = simulation.tout;
ref_speed = simulation.ref_speed.data;
actual_speed = simulation.actual_speed.data;

cost = sum(trapz(time_steps, abs(actual_speed - ref_speed).*time_steps));

end



