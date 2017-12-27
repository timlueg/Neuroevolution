%vorgegebene Netzwerkstruktur
num_input=2;
num_output=2;
num_networks = 5;

%Definition der Knoten
node_num_fields = 2;
global node_id
node_id = 0;
node_columnNames = {'id', 'type'};
node_type_sensor = 1;
node_type_hidden = 2;
node_type_output = 3;

%Definition der Verbindungen
connection_num_fields = 5;
innov_id = 0;
connection_columnNames = {'InputNodeId', 'OutNodeId', 'Weight', 'State', 'InnovId'};
conn_state_enabled = 1;

global nodes
global connections
nodes={};
connections={};
%Initialisierung

for i=1:num_networks
    nodes{i} = zeros(0, node_num_fields);
    for j=1:num_input
        addNode(node_type_sensor,i);
    end
    for j=1:num_output
        addNode(node_type_output,i);
    end
    connections{i} = zeros(0, connection_num_fields);
    for j=1:num_input
       for k=1:num_output
           addConnection(j,num_input+k,rand(1),conn_state_enabled,innov_id,i);
       end
    end

end

%array2table(nodes, 'VariableNames', node_columnNames)
%array2table(connections, 'VariableNames', connection_columnNames)

%addConnection(1, 2, 0.4, conn_state_disabled, 1)

function addNode(type,num_net)
global node_id
global nodes
node_id = node_id +1;

nodes{num_net} = [nodes{num_net};  node_id, type];

end

function addConnection(inNodeId, outNodeId, weight, state, InnovId,num_net)
global connections
connections{num_net} = [connections{num_net}; inNodeId, outNodeId, weight, state, InnovId];
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