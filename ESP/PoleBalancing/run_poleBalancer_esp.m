function [fitness, steps] = run_poleBalancer_esp(W, act)

%clear;
headless = true;    % removes visualizations from the simulation
cfg = twoPole;        % contains the simulation configuration
SystemInit;         % some Matlab initialization

% This should point to your activation function, which will receive these
% parameters. Feel free to change the structure if you need more!
% ind      ind object, containing weights, configuration, etc.
% input    will contain the input plus the bias on the input layer. Feel
%          free to ignore the bias if you handle it in a different way
cfg.activate = @activate_recurrent;

%% Configure your algorithm
%% !This is just an example. Please use your *own* configuration variables
% cfg.num_inputs = cfg.inputs;
% cfg.num_outputs = cfg.outputs;
% cfg.num_layers = 1;
% cfg.num_hid_per_lay = 2;
% cfg.mu_init = 0.1;
% cfg.actFn = @tanh;

runs = 1;
for i=1:runs
    %% !insert your network here
    %ind = poleBalancer_esp.initialize_recurrent(cfg);
    ind.W = W;
    ind.act = act;
    ind.actFn = @tanh;
    if ~headless
        % the 'ind' object will be inserted into your activation function!
        [fitness(i), steps(i)] = twoPole_test( ind, cfg, 'vis'); 
        %figure(999);
        %semilogy(steps');
        hold on;
        semilogy(fitness');
        drawnow;
        figure(2);
    else
        [fitness(i), steps(i)] = twoPole_test( ind, cfg); 
    end
    disp(['Steps achieved: ' int2str(steps(end)) ', corresponding to fitness: ' num2str(fitness(end))]);
    %disp(['Max steps was: ' int2str(max(steps))]);
end
% 
% figure(999);
% semilogy(steps');
% hold on;
% semilogy(fitness');

end