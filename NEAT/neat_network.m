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

%Hyperparameter
num_Iterations = 10;
params.weightMutationRate = 0.9;
params.standardDeviation = 0.05;
params.genomeRemovalRate = 0.20; 

%network structure
params.num_input = 2;
params.num_output = 1;
params.num_networks = 5;

%distance parameter
params.c1 = 1;
params.c2 = 1;
params.c3 = 0.4;

%species parameter
params.species_target = 10;
params.species_distance = 6;

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
params.species = zeros(params.num_networks,1);
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
        params = addConnection(aktuelleKnoten + j, aktuelleKnoten + params.num_input + k, randn, params.conn_state_enabled, 1, params);
    end
end

%copy network
params.nodes(1,:) = {params.nodes{1}};
params.connections(1,:) = {params.connections{1}};

%mutate basic networks
for i=1:params.num_networks
    params = mutateWeights(i, params);
end

%display matrix example
array2table(params.nodes{1}, 'VariableNames', params.node_columnNames)
array2table(params.connections{1}, 'VariableNames', params.connection_columnNames)

for i=1:num_Iterations
    params = defineSpecies(params);
    params = fitnessCalculation(params);
    
    %remove less fit genes
    [fitnessArray, sortIndex] = sort(params.fitness, 'ascend');
    num_GenomesSelected = params.num_networks * (1-params.genomeRemovalRate);
    sortIndex = sortIndex(1:num_GenomesSelected);
    params.connections = params.connections(sortIndex);
    params.nodes = params.nodes(sortIndex);
    params.species = params.species(sortIndex);
    params.fitness = params.fitness(sortIndex);
    %todo veraendern durch Mutation/Crossover innerhalb einer species bis Groe�e wieder aufgefuellt
    
end

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

function [params] = mutateWeights(netIndex, params)
for i=1:size(params.connections{netIndex},1)
    if rand(1) < params.weightMutationRate
        params.connections{netIndex}(i,3) = params.connections{netIndex}(i,3) + normrnd(0,params.standardDeviation);
    end
end
end

function [params] = mutateAddConnection(netIndex, params)
existingConnections = params.connections{netIndex}(:,1:2);

%randomConnections = randi([min(existingConnections(:)), max(existingConnections(:))],[4,2]);
randomConnections(:,1) = randi([min(existingConnections(:)), max(existingConnections(:))],[4,1]);
randomConnections(:,2) = randi([params.num_input+1, max(existingConnections(:))],[4,1]);
difference = setdiff(randomConnections, existingConnections, 'rows');
if ( size(difference, 1) ~= 0)
    newConnection = difference(1,:);
    params = addConnection(newConnection(1), newConnection(2), randn, params.conn_state_enabled, netIndex, params);
end
end


function [offspringConnections] = crossover(parent, parentHigherFit, params)
[~, intersectParent1Idx, intersectParent2Idx] = intersect(parent(:, params.connCol_innovId),  parentHigherFit(:, params.connCol_innovId));
[~, disjointExcessIdx] = setdiff(parentHigherFit(:, params.connCol_innovId), parent(:, params.connCol_innovId));

ParentsConcatinated = [parent; parentHigherFit];
intersectIdx = [intersectParent1Idx, (intersectParent2Idx + size(parent,1))];
intersectIdxColumnSelector = randi(2,1, size(intersectIdx,1));
randomIntersectConnections = ParentsConcatinated(sub2ind(size(intersectIdx), 1:size(intersectIdx,1), intersectIdxColumnSelector),:);
parentHigherFitDisExConnections = parentHigherFit(disjointExcessIdx,:);
offspringConnections = [randomIntersectConnections; parentHigherFitDisExConnections];
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

%anhaengen von Flag zum ueberpruefen ob vorgekommen
connectionListe1 = [connectionList1, zeros(size1,1)];
connectionListe2 = [connectionList2, zeros(size2,1)];

% Punkt finden fuer die Excess genome
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

%durchgehen von denen die in der groesseren Liste nicht behandelt wurden
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
params.species(1) = 1;
species_count = 1;

for i=2:size(params.nodes,2)
    
    for j=1:i-1
        distance = distanceOf(params.connections{i},params.connections{j},params);
        if distance <= params.species_distance
            params.species(i) = params.species(j);
        end
    end
    if params.species(i)==0
        species_count = species_count +1;
        params.species(i) = species_count;
    end
    
end
if species_count < params.species_target
    params.species_distance = params.species_distance - 0.3;
end
if species_count > params.species_target
    params.species_distance = params.species_distance + 0.3;
end
end

function [params] = fitnessCalculation(params)
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