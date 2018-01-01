%load Data
load ('trainingData.mat','tdata')

%normalize dataset
for i=1:size(tdata,2)
    tdata{i} = mapminmax(tdata{i}')';
end

params.train_data = {tdata{1:10}};
params.test_data = {tdata{10:12}};

params.num_Training = size(params.train_data,2);
params.num_Test = size(params.test_data,2);

%Trainingparameters
num_Iterations = 10;

%network structure
params.num_input = 2;
params.num_output = 1;
params.num_networks = 5;

%distance parameter
params.c1 = 1;
params.c2 = 1;
params.c3 = 1;

%spezies parameter
params.spezies_target = 10;
params.spezies_distance = 6;

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

params.nodes = cell(1, params.num_networks);
params.connections = cell(1, params.num_networks);
params.spezies = zeros(params.num_networks,1);
params.fitness = zeros(params.num_networks,1);

%Initial basic network
aktuelleKnoten= params.nodeId;
params.nodes{1} = zeros(0, params.node_num_fields);
for j=1:params.num_input
    params = appendNode(params.node_type_sensor, 1, params);
end
for j=1:params.num_output
    params = appendNode(params.node_type_output, 1, params);
end
params.connections{1} = zeros(0, params.connection_num_fields);
for j=1:params.num_input
    for k=1:params.num_output
        params = addConnection(aktuelleKnoten + j, aktuelleKnoten + params.num_input + k, rand, params.conn_state_enabled, 1, params);
    end
end

%copy network
params.nodes(1,:) = {params.nodes{1}};
params.connections(1,:) = {params.connections{1}};

%todo mutate basic networks

%display matrix example
array2table(params.nodes{1}, 'VariableNames', params.node_columnNames)
array2table(params.connections{1}, 'VariableNames', params.connection_columnNames)

for i=1:num_Iterations
    %todo spezien bilden
    params = defineSpecies(params);
    %todo bewerten
    params = fitnessCalculating(params);
    %todo schlechteste rauswerfen
    %todo verändern durch Mutation/Crossover innerhalb einer Spezies bis Größe wieder aufgefüllt
end

%test crossover
mutatedparams = mutateAddNode(1, 3, 1, params);
crossover(params.connections{1}, mutatedparams.connections{1}, params)

%test distance
a= [1,3,0.0527,1,1;
    1,4,0.7379,0,2;
    2,3,0.29,1,3;
    2,4,0.422,1,4];
b= [1,3,0.0527,1,1;
    1,4,0.7379,0,2;
    2,3,0.29,1,3];
distanceOf(a,b,params);

%test defineSpezies
params = defineSpecies(params);

%test fitnessCalculating
params = fitnessCalculating(params);



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
[~, disjointExcessIdx] = setdiff(parentHigherFitness(:, params.connCol_innovId), parentLowerFitness(:, params.connCol_innovId));

ParentsConcatinated = [parentLowerFitness; parentHigherFitness];
intersectIdx = [intersectParent1Idx, (intersectParent2Idx + size(parentLowerFitness,1))];
intersectIdxColumnSelector = randi(2,1, size(intersectIdx,1));
randomIntersectConnections = ParentsConcatinated(sub2ind(size(intersectIdx), 1:size(intersectIdx,1), intersectIdxColumnSelector),:);
parentHigherFitDisExConnections = parentHigherFitness(disjointExcessIdx,:);
offspring = [randomIntersectConnections; parentHigherFitDisExConnections];
%todo add nodes to network, maybe use global node table for all netwoks.
%(why do we need to keep track)
end

function [distance] = distanceOf(connectionList1,connectionList2,params)
size1 = size(connectionList1,1);
size2 = size(connectionList2,1);

% kleinere Liste ist Liste 1
if size1 > size2
    tmp = size2;
    size2 = size1;
    size1 = tmp;
    tmp1 = connectionList2;
    connectionList2 = connectionList1;
    connectionList1 = tmp1;
end

%anhï¿½ngen von Flag zum ï¿½berprï¿½fen ob vorgekommen
connectionListe1 = [connectionList1, zeros(size1,1)];
connectionListe2 = [connectionList2, zeros(size2,1)];

% Punkt finden fï¿½r die Excess genome
maxInnovId1 = max(connectionList1(:,5));
maxInnovId2 = max(connectionList2(:,5));
if maxInnovId1 > maxInnovId2
    klInnovId = maxInnovId2;
else
    klInnovId = maxInnovId1;
end

N = size2;
E = 0;
D = 0;
W = 0;
matching_counter = 0;

%Liste1 durchgehen
for i=1:size1
    zeile1 = connectionListe1(i,:);
    %gucken ob Kante der einen Liste in der anderen auftaucht.
    for j=1:size2
        zeile2 = connectionListe2(j,:);
        %gleiche Kante
        if zeile1(5) == zeile2(5)
            matching_counter = matching_counter +1;
            W = W + abs(zeile1(3)-zeile2(3));
            %Flag setzen
            connectionListe1(i,6) = 1;
            connectionListe2(j,6) = 1;
        end
    end
    if connectionListe1(i,6)==0
        %disjungt oder extra
        if zeile1(5)>klInnovId
            E = E +1;
            connectionListe1(i,6) = 1;
        else
            D = D +1;
            connectionListe1(i,6) = 1;
        end
    end
    
    
end

%durchgehen von denen die in der grï¿½ï¿½eren Liste nicht behandelt wurden
for i=1:size2
    if connectionListe2(i,6)==0
        %disjungt oder extra
        if zeile1(5)>klInnovId
            E = E +1;
            connectionListe2(i,6) = 1;
        else
            D = D +1;
            connectionListe2(i,6) = 1;
        end
    end
end

if matching_counter ==0
    matching_counter = 1;
end
%gewichte mitteln
avgW = W/matching_counter;

distance = ((params.c1 * E)/N) + ((params.c2 * D)/ N) + params.c3 * avgW;

end

function [params] = defineSpecies(params)
params.spezies(1) = 1;
spezies_count = 1;

for i=2:size(params.nodes,2)
    
    for j=1:i-1
        distance = distanceOf(params.connections{i},params.connections{j},params);
        if distance <= params.spezies_distance
            params.spezies(i) = params.spezies(j);
        end
    end
    if params.spezies(i)==0
        spezies_count = spezies_count +1;
        params.spezies(i) = spezies_count;
    end
    
end
if spezies_count < params.spezies_target
    params.spezies_distance = params.spezies_distance - 0.3;
end
if spezies_count > params.spezies_target
    params.spezies_distance = params.spezies_distance + 0.3;
end
end

function [params] = fitnessCalculating(params)
for i=1:params.num_networks
    
    weightMatrix = phenotyp(params.nodes{i},params.connections{i});
    if params.num_input+1 == size(params.nodes{i},1)
        weightMatrix = weightMatrix(:,[params.num_input+1]);
    else
        weightMatrix = weightMatrix(:,[params.num_input+1;size(params.nodes{i},1)]);
    end
    
    fehler = 0;
    
    for j=1:params.num_Training
        currentActivation = zeros(1, size(params.nodes{i},1) - params.num_input);
        numTrainingRows = size(params.train_data{j},1);
        for k=1:numTrainingRows
            input = [params.train_data{j}(k,1),params.train_data{j}(k,3)];
            netOut = [input, currentActivation] * weightMatrix;
            netOut = tanh(netOut);
            currentActivation = netOut;
            
            heartrate_pred = netOut(1);
            netFitness = fitness(params.train_data{j}(k,2), heartrate_pred);
            fehler = fehler + netFitness;
            
        end
    end
    params.fitness(i)=fehler;
end
end
function [error]= fitness(target,out)
error= (0.5* (target-out)^2);
end