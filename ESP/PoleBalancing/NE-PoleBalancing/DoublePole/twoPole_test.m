function [ fitness, steps ] = twoPole_test( ind, p, varargin)
%TWOPOLE_TEST Double pole balancing
% Copyright Alexander Hagg BRSU 2016
%   See cart_pole2.m for details and original authors
%   state = [ x           <- the cart position
%             x_dot       <- the cart velocity
%             theta       <- the angle of the pole
%             theta_dot   <- the angular velocity of the pole.
%             theta2      <- the angle of the 2nd pole
%             thet2a_dot  <- the angular velocity of the 2nd pole.
%
% environment parameters (these MUST match the corresponding values in cart_pole.m)

%% Initialization
vis = false;
initial_state = [0 0 .017 0 0.0 0]';
simLength = p.targetFitness;

if nargin > 2 
    if strcmp(varargin{end},'vis')
        vis = true;
        axis_range = [-3 3 0 2];
        hf = figure; % generate a new figure to be used by cpvisual()
        hf2 =figure; % generate a new figure to be used by cpvisual2()
        tic; % initialize timer, which is used to make animation with cpvisual()
        % more realistic.
    end
    
    if strcmp(varargin{1},'full')
        simLength = p.maxFitness;
    end
    
    if strcmp(varargin{1},'setInit')
        initial_state = varargin{2};
    end
end


twoPole_sim_cfg;

%% Sim loop
while ( abs(state(3)) < pi/2 && ...       % Pole #1
        abs(state(5)) < pi/2 && ...    % Pole #2
        abs(state(1)) < 2.16 && ...    % Cart still on track
        abs(state(2)) < 1.35 && ...    % Cart never too fast
        steps < simLength)
    
    steps = steps + 1;
    
    %% Action Selection
    scaledInput = state./scaling;
    if p.velInfo
        input = scaledInput';
    else
        input = scaledInput([1 3 5])';
    end
    
    % Activate network
    output = p.activate(ind,[bias input]);

    action = (-0.5+output).*2.*force;
    
    if vis
        % Visualization
        while toc < tau, end % wait until at least the time between state
        % changes, tau, has passed since the last graph.
        cpvisual( hf, pole_length, state(1:4), axis_range, action );
        cpvisual( hf2, pole_length2, state([1 2 5 6]), axis_range, action );
        tic; % reset timer (used for realistic visualization)
        TSteps = steps;
    end
    
    
    % Take action and return new state:
    state = cart_pole2( state, action );
    
    scaledState = state./scaling;
    f2_den(steps,:) = scaledState([1:4]);
end

%% Fitness Calculation
if ~p.gruau
    fitness = steps;
else
    % Oscillation penalizing fitness.
    f1 = steps/p.targetFitness;
    if steps>100
        f2 = sum((sum (abs(  f2_den((end-99:end),:)  ))));
        %f2 = f2/10;
        f2 = (1/f2) * 0.75;
    else
        f2 = 0;
    end
    fitness = 0.1*f1 + 0.9*f2;
end

