%network structure
num_input = 2;
num_output = 2;
num_networks = 5;

%node constants
params.node_columnNames = {'id', 'type'};
params.nodeCol_id = 1;
params.nodeCol_type = 2;
params.node_num_fields = size(params.node_columnNames,2);

params.nodeId = 0;
params.node_type_sensor = 1;
params.node_type_hidden = 2;
params.node_type_output = 3;

%connection constants
params.connection_columnNames = {'InputNodeId', 'OutNodeId', 'Weight', 'State', 'InnovId'};
params.connCol_input = 1;
params.connCol_output = 2;
params.connCol_weight = 3;
params.connCol_state = 4;
params.connCol_innovId = 5;
params.connection_num_fields = size(params.connection_columnNames,2);

params.innovId = 0;
params.conn_state_enabled = 1;

params.nodes = cell(1, num_networks);
params.connections = cell(1, num_networks);

%Initial basic network
aktuelleKnoten= params.nodeId;
params.nodes{1} = zeros(0, params.node_num_fields);
for j=1:num_input
    params = appendNode(params.node_type_sensor, 1, params);
end
for j=1:num_output
    params = appendNode(params.node_type_output, 1, params);
end
params.connections{1} = zeros(0, params.connection_num_fields);
for j=1:num_input
    for k=1:num_output
        params = addConnection(aktuelleKnoten + j, aktuelleKnoten + num_input + k, rand, params.conn_state_enabled, 1, params);
    end
end

%copy network
params.nodes(1,:) = {params.nodes{1}};
params.connections(1,:) = {params.connections{1}};

%todo mutate basic networks

%display matrix example
array2table(params.nodes{1}, 'VariableNames', params.node_columnNames)
array2table(params.connections{1}, 'VariableNames', params.connection_columnNames)

%test crossover
mutatedparams = mutateAddNode(1, 3, 1, params);
crossover(params.connections{1}, mutatedparams.connections{1}, params)


function [params] = appendNode(type, netIndex, params)
params.nodeId = params.nodeId + 1;
params.nodes{netIndex} = [params.nodes{netIndex};  params.nodeId, type];
end

function [params] = addConnection(inNodeId, outNodeId, weight, state, netIndex, params)
params.innovId = params.innovId + 1;
params.connections{netIndex} = [params.connections{netIndex}; inNodeId, outNodeId, weight, state, params.innovId];
end

function [params] = enableConnection(inNodeId, outNodeId, netIndex, params)
for i=1:size(params.connections{netIndex},1)
    if params.connections{netIndex}(i, params.connCol_input) == inNodeId && params.connections{netIndex}(i, params.connCol_output) == outNodeId
        params.connections{netIndex}(i, params.connCol_state) = params.conn_state_enabled;
    end
end
end

function [params] = disableConnection(inNodeId, outNodeId, netIndex, params)
for i=1:size(params.connections{netIndex},1)
    if params.connections{netIndex}(i, params.connCol_input) == inNodeId && params.connections{netIndex}(i, params.connCol_output) == outNodeId
        params.connections{netIndex}(i, params.connCol_state) = ~params.conn_state_enabled;
    end
end
end

function [params] = toggleConnectionState(inNodeId, outNodeId, netIndex, params)
for i=1:size(params.connections{netIndex},1)
    if params.connections{netIndex}(i, params.connCol_input) == inNodeId && params.connections{netIndex}(i, params.connCol_output) == outNodeId
        params.connections{netIndex}(i, params.connCol_state) =  ~params.connections{netIndex}(i, params.connCol_state);
    end
end
end

function [params] = mutateAddNode(inNodeId, outNodeId, netIndex, params)
params = appendNode(params.node_type_hidden, netIndex, params);
params = disableConnection(inNodeId, outNodeId, netIndex, params);
oldweight = params.connections{netIndex}(params.connections{netIndex}(:, params.connCol_input) == inNodeId & params.connections{netIndex}(:,params.connCol_output) == outNodeId, params.connCol_weight);
params = addConnection(inNodeId, params.nodeId, 1, params.conn_state_enabled, netIndex, params);
params = addConnection(params.nodeId, outNodeId, oldweight, params.conn_state_enabled, netIndex, params);
end

function [offspring] = crossover(parentLowerFitness, parentHigherFitness, params)
[~, intersectParent1Idx, intersectParent2Idx] = intersect(parentLowerFitness(:, params.connCol_innovId),  parentHigherFitness(:, params.connCol_innovId));
[~, disjointExcessIdx] = setdiff(parentHigherFitness(:, params.connCol_innovId), parentLowerFitness(:, params.connCol_innovId))
%todo randomly inherit intersect genes
%todo inherit all disjointExessidx of parentHigherFitness 
end
