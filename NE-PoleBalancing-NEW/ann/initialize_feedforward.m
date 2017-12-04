function nw = mlp_init_random( cfg )
%MLP_INIT_RANDOM Random initialization of MLP weights
%   nw = mlp_init_random(x,cfg) Randomly initialize MLP, returns a network
%   object
%   cfg.num_inputs Number of input dimensions
%   cfg.num_outputs Number of output dimensions
%   cfg.num_layers Number of layers
%   cfg.num_hid_per_lay Number of hidden neurons per layer

nw.cfg = cfg;
for l=1:cfg.num_layers+1
    if l < cfg.num_layers+1;num_neurons = cfg.num_hid_per_lay;else;num_neurons = cfg.num_outputs;end

    if l == 1
        nw.W{l} = cfg.mu_init * randn( 1 + cfg.num_inputs,num_neurons);
    else
        nw.W{l} = cfg.mu_init * randn( 1 + cfg.num_hid_per_lay,num_neurons);
    end
end
end

