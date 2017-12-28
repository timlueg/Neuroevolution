%vorgegebene Netzwerkstruktur
num_input = 2;
num_output = 2;
num_networks = 5;

%Definition der Knoten
params.node_columnNames = {'id', 'type'};
params.node_num_fields = size(node_columnNames,2);
params.nodeId = 0;
params.node_type_sensor = 1;
params.node_type_hidden = 2;
params.node_type_output = 3;

%Definition der Verbindungen
params.connection_columnNames = {'InputNodeId', 'OutNodeId', 'Weight', 'State', 'InnovId'};
params.connection_num_fields = size(connection_columnNames,2);
params.innovId = 0;
params.conn_state_enabled = 1;

%global nodes
%global connections
params.nodes = cell(1, num_networks);
params.connections = cell(1, num_networks);

%Initialisierung
for i=1:num_networks
    aktuelleKnoten= params.nodeId;
    params.nodes{i} = zeros(0, node_num_fields);
    for j=1:num_input
        params = addNode(params.node_type_sensor, i, params);
    end
    for j=1:num_output
        params = addNode(params.node_type_output, i, params);
    end
    params.connections{i} = zeros(0, connection_num_fields);
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

function [params] = enableConnectionState(inNodeId, outNodeId, netIndex, params)
for i=1:size(params.connections{netIndex},1)
    if params.connections{netIndex}(i,1) == inNodeId && params.connections{netIndex}(i,2) == outNodeId
        params.connections{netIndex}(i,4) = params.conn_state_enabled;
    end
end
end

function [params] = disableConnectionState(inNodeId, outNodeId, netIndex, params)
for i=1:size(params.connections{netIndex},1)
    if params.connections{netIndex}(i,1) == inNodeId && params.connections{netIndex}(i,2) == outNodeId
        params.connections{netIndex}(i,4) = ~params.conn_state_enabled;
    end
end
end

function [params] = toggleConnectionState(inNodeId, outNodeId, netIndex, params)
for i=1:size(params.connections{netIndex},1)
    if params.connections{netIndex}(i,1) == inNodeId && params.connections{netIndex}(i,2) == outNodeId
        params.connections{netIndex}(i,4) =  mod(params.connections{netIndex}(i,4) + 1, 2);
    end
end
end

function [params] = splitConnection(inNodeId, outNodeId, netIndex, params)
params = addNode(params.node_type_hidden, netIndex, params);
params = disableConnectionState(inNodeId, outNodeId, netIndex, params);
oldweight = params.connections{netIndex}(find(params.connections{netIndex}(:,1) == inNodeId & params.connections{netIndex}(:,2) == outNodeId), 3);
params = addConnection(inNodeId, params.nodeId, 1, 1, params.innovId, netIndex);
params = addConnection(params.nodeId, outNodeId, oldweight, 1, params.innovId, netIndex);
end