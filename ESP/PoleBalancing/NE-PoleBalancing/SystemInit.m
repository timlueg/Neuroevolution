%% SYSTEMINIT.M - System parameter setup: parallelization, random numbers, figure docking
%
% Setup of system parameters:
% * Parallelization
% * Random number stream
% * Figure docking

% Parallalization
if cfg.parallel
    if isempty(gcp('nocreate'))
        myPool = parpool('IdleTimeout', 120);
    end
end

% Random number stream
randSteam = RandStream('mt19937ar','Seed','shuffle');
RandStream.setGlobalStream(randSteam);

% Dock new figures rather than opening new ones
set(0,'DefaultFigureWindowStyle','docked')