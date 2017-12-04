pole_length = 0.5*2; % full pole length (not just half as in cart_pole.m)
pole_length2 = 0.05*2; % full pole length (not just half as in cart_pole.m)
tau = 0.01; % time between each step (in s)
state = initial_state; % initial state (note, it is a column vector) (1 degree = .017 rad)
force = 10;
steps = 0;
bias = 1;

scaling = [ 2.4 10.0 0.628329 5 0.628329 16]';