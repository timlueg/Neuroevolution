%vorgegebene Netzwerkstruktur
num_input = 2;
num_output = 2;
num_networks = 5;

%Definition der Knoten
params.node_columnNames = {'id', 'type'};
params.nodeCol_id = 1;
params.nodeCol_type = 2;
params.node_num_fields = size(params.node_columnNames,2);

params.nodeId = 0;
params.node_type_sensor = 1;
params.node_type_hidden = 2;
params.node_type_output = 3;

%Definition der Verbindungen
params.connection_columnNames = {'InputNodeId', 'OutNodeId', 'Weight', 'State', 'InnovId'};
params.connCol_input = 1;
params.connCol_output = 2;
params.connCol_weight = 3;
params.connCol_state = 4;
params.connCol_innovId = 5;
params.connection_num_fields = size(params.connection_columnNames,2);

params.innovId = 0;
params.conn_state_enabled = 1;

%global nodes
%global connections
params.nodes = cell(1, num_networks);
params.connections = cell(1, num_networks);

%Initialisierung
for i=1:num_networks
    aktuelleKnoten= params.nodeId;
    params.nodes{i} = zeros(0, params.node_num_fields);
    for j=1:num_input
        params = addNode(params.node_type_sensor, i, params);
    end
    for j=1:num_output
        params = addNode(params.node_type_output, i, params);
    end
    params.connections{i} = zeros(0, params.connection_num_fields);
    for j=1:num_input
        for k=1:num_output
            params = addConnection(aktuelleKnoten + j, aktuelleKnoten + num_input + k, rand(1), params.conn_state_enabled, params.innovId, i, params);
        end
    end
    
end

%Visualisierung
array2table(params.nodes{1}, 'VariableNames', params.node_columnNames)
array2table(params.connections{1}, 'VariableNames', params.connection_columnNames)


function [params] = addNode(type, netIndex, params)
params.nodeId = params.nodeId + 1;
params.nodes{netIndex} = [params.nodes{netIndex};  params.nodeId, type];
end

function [params] = addConnection(inNodeId, outNodeId, weight, state, InnovId, netIndex, params)
params.connections{netIndex} = [params.connections{netIndex}; inNodeId, outNodeId, weight, state, InnovId];
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

function [params] = splitConnection(inNodeId, outNodeId, netIndex, params)
params = addNode(params.node_type_hidden, netIndex, params);
params = disableConnection(inNodeId, outNodeId, netIndex, params);
oldweight = params.connections{netIndex}(params.connections{netIndex}(:, params.connCol_input) == inNodeId & params.connections{netIndex}(:,params.connCol_output) == outNodeId, params.connCol_weight);
params = addConnection(inNodeId, params.nodeId, 1, params.conn_state_enabled, params.innovId, netIndex, params);
params = addConnection(params.nodeId, outNodeId, oldweight, params.conn_state_enabled, params.innovId, netIndex, params);
end