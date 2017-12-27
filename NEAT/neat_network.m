node_num_fields = 2;
num_networks = 5;
global node_id
node_id = 0;
node_columnNames = {'id', 'type'};
node_type_sensor = 1;
node_type_hidden = 2;
node_type_output = 3;

connection_num_fields = 5;
innov_id = 0;
connection_columnNames = {'InputNodeId', 'OutNodeId', 'Weight', 'State', 'InnovId'};
conn_state_enabled = 1;

global nodes
global connections

nodes = zeros(0, node_num_fields, num_networks);
connections = zeros(0, connection_num_fields, num_networks);

array2table(nodes, 'VariableNames', node_columnNames)
array2table(connections, 'VariableNames', connection_columnNames)

addNode(node_type_sensor);
addConnection(1, 2, 0.4, conn_state_disabled, 1)

function addNode(type)
    global node_id
    global nodes
    node_id = node_id +1;
    nodes = [nodes;  node_id, type];
end

function addConnection(inNodeId, outNodeId, weight, state, InnovId)
    global connections
    connections = [connections; inNodeId, outNodeId, weight, state, InnovId];
end

function enableConnectionState(inNodeId, outNodeId)
    global connections
    for i=1:size(connections,1)
        if connections(i,1) == inNodeId && connections(i,2) == outNodeId
            connections(i,4) = conn_state_enabled;
        end
    end
end

function disableConnectionState(inNodeId, outNodeId)
    global connections
    for i=1:size(connections,1)
        if connections(i,1) == inNodeId && connections(i,2) == outNodeId
            connections(i,4) = conn_state_disabled;
        end
    end
end

function toggleConnectionState(inNodeId, outNodeId)
    global connections
    for i=1:size(connections,1)
        if connections(i,1) == inNodeId && connections(i,2) == outNodeId
            connections(i,4) =  mod(connections(i,4) + 1, 2);
        end
    end
end