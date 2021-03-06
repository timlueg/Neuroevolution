function [out, ind] = activate_recurrent( ind, input)
%ACTIVATE_FEEDFORWARD activates your feed forward neural network
% ind      ind object, containing weights, configuration, etc.
% input    will contain the input plus the bias on the input layer. Feel
%          free to ignore the bias if you handle it in a different way

netOut = ind.actFn([input, ind.act] * ind.W');

out = netOut(end);

ind.act = netOut;

end

