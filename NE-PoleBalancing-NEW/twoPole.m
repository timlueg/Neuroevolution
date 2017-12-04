%% TwoPole Balancing parameters from Original NEAT Paper
%
%
function p = twoPole
p.name = 'TwoPole_{NE}';
p.recurrent = false;
p.parallel = false;

% Algorithm Parameters
p.maxGen = 20;
p.popSize= 20;

% Network Parameters
p.recurrent = false;
p.velInfo = true;

% Fitness Function
p.fitFun = @twoPole_test;
p.stoppingCriteria = @FullTwoPoleTest;

% With Velocities (for Feed Forward Neural Network)
p.inputs = 6; %x, x_dot, theta1, theta1_dot, theta2, theta2_dot
p.activations = 1; %bias activation
p.activations = [p.activations 1 1 1 1 1 1];   

% Without Velocities
%p.inputs = 3; %x, x_dot, theta1, theta1_dot, theta2, theta2_dot
%p.activations = 1; %bias activation
%p.activations = [p.activations 1 1 1];  

p.outputs = 1;
p.activations = [p.activations,3];

% Fitness parameters for Gruau double pole benchmark
p.gruau = true;         % Oscillation fitness and generality tests
p.targetFitness = 1000;
p.maxFitness =  100000; % Steps to prove solving of upright state
p.generalization = 200; % Min number off for number of states for success
p.oldFit = 0;

% Additional individual fitness information
p.sampleInd.fitness = 0;
p.sampleInd.steps = 0;
p.sampleInd.complete = false;
p.sampleInd.generalization = 0;

% Visualization Parameters
displayParams;

p.startPlot = 3;
