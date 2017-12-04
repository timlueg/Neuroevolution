function [out, act] = activate_feedforward( ind, input)
%ACTIVATE_FEEDFORWARD activates your feed forward neural network
% ind      ind object, containing weights, configuration, etc.
% input    will contain the input plus the bias on the input layer. Feel
%          free to ignore the bias if you handle it in a different way

% Input and bias
act{1} = zeros(size(input,2),ind.cfg.num_inputs);
act{1} = input;

for l=2:ind.cfg.num_layers+2
    if l == 2; act{l} = act{l-1}*ind.W{l-1};end
    if l > 2; act{l} = [1,act{l-1}]*ind.W{l-1};end
    act{l} = ind.cfg.actFn(act{l});
end
out = act{end};
end

