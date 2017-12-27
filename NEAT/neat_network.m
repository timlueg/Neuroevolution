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
global innov_id
innov_id = 0;
connection_columnNames = {'InputNodeId', 'OutNodeId', 'Weight', 'State', 'InnovId'};
conn_state_enabled = 1;

global nodes
global connections
nodes={};
connections={};
%Initialisierung

for i=1:num_networks
    aktuelleKnoten=node_id;
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
           addConnection(aktuelleKnoten+ j,aktuelleKnoten+ num_input+k,rand(1),conn_state_enabled,innov_id,i);
       end
    end

end

%Visualisierung
array2table(nodes{1}, 'VariableNames', node_columnNames)
array2table(connections{1}, 'VariableNames', connection_columnNames)


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

function enableConnectionState(inNodeId, outNodeId,num_net)
global connections
for i=1:size(connections{num_net},1)
    if connections{num_net}(i,1) == inNodeId && connections{num_net}(i,2) == outNodeId
        connections{num_net}(i,4) = conn_state_enabled;
    end
end
end

function disableConnectionState(inNodeId, outNodeId,num_net)
global connections
for i=1:size(connections{num_net},1)
    if connections{num_net}(i,1) == inNodeId && connections{num_net}(i,2) == outNodeId
        connections{num_net}(i,4) = 0;
    end
end
end

function toggleConnectionState(inNodeId, outNodeId,num_net)
global connections
for i=1:size(connections{num_net},1)
    if connections{num_net}(i,1) == inNodeId && connections{num_net}(i,2) == outNodeId
        connections{num_net}(i,4) =  mod(connections{num_net}(i,4) + 1, 2);
    end
end
end
function splitConnection(inNodeId,outNodeId,num_net)
global connections
global node_id
global innov_id
addNode(2,num_net);
disableConnectionState(inNodeId,outNodeId,num_net);
oldweight= connections{num_net}(find(connections{num_net}(:,1)== inNodeId & connections{num_net}(:,2)== outNodeId),3);
addConnection(inNodeId, node_id, 1, 1, innov_id,num_net);
addConnection(node_id, outNodeId, oldweight, 1, innov_id,num_net);

end