%function [allElite,allMedian,allNodes,allConnections] = neat_network(num_Iterations)
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
num_Iterations = 200;
params.weightMutationRate = 0.8;
params.singleWeightMutationRate = 0.9;
params.singleWeightRandomResetRate = 0.1;
params.addNodeMutationRate = 0.03;
params.addConnectionMutationRate = 0.05;
params.standardDeviation = 0.02;
params.genomeRemovalRate = 0.2;

%statistics
allElite= zeros(1,num_Iterations);
allMedian= zeros(1,num_Iterations);
allNodes = zeros(1,num_Iterations);
allConnections = zeros(1,num_Iterations);
allTopologies = zeros(1,num_Iterations);

%network structure
params.num_input = 2;
params.num_output = 1;
params.num_networks = 30;

%distance parameter
params.c1 = 1;
params.c2 = 1;
params.c3 = 0.4;

%species parameter
params.species_target = 4;
params.species_distance = 1;

%node constants
params.node_columnNames = {'id', 'type'};
params.nodeCol_id = 1;
params.nodeCol_type = 2;
params.node_num_fields = length(params.node_columnNames);

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
params.connection_num_fields = length(params.connection_columnNames);

params.innovId = 0;
params.conn_state_enabled = 1;

params.nodes = cell(1, params.num_networks);
params.connections = cell(1, params.num_networks);
params.species = zeros(params.num_networks,1);
params.fitness = zeros(params.num_networks,1);
params.sharedfitness = zeros(params.num_networks,1);

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
    %disp(params.species);
    %disp(params.species_distance);
    params = sharedFitness(params);
    %remove less fit genes
    [fitnessArray, sortIndex] = sort(params.fitness, 'ascend');
    num_genomesRemoved = floor(size(params.connections,2) * params.genomeRemovalRate);
    num_genomesSelected = floor(size(params.connections,2) * (1-params.genomeRemovalRate));
    sortIndex = sortIndex(1:num_genomesSelected);
    params.connections = params.connections(sortIndex);
    params.nodes = params.nodes(sortIndex);
    params.species = params.species(sortIndex);
    params.fitness = params.fitness(sortIndex);
    %todo veraendern durch Mutation/Crossover innerhalb einer species bis Groe�e wieder aufgefuellt
    
    %index of elite for each species (with >=5 networks)
    num_species = max(params.species);
    num_genomesInSpecies = zeros(1, num_species);
    for j=1:length(params.species)
        num_genomesInSpecies(params.species(j))= num_genomesInSpecies(params.species(j)) + 1;
    end
    grosseSpecies = find(num_genomesInSpecies >= 5);
    eliteIndex = zeros(1,length(grosseSpecies));
    if(~isempty(grosseSpecies))
        for j=1:length(grosseSpecies)
            minValue=Inf;
            minIndex=0;
            for k=1:length(params.fitness)
                if params.species(k)== grosseSpecies(j)
                    if params.fitness(k) < minValue
                        minValue = params.fitness(k);
                        minIndex = k;
                    end
                end
            end
            eliteIndex(j) = minIndex;
        end
    end
    
    
    %todo use fitnesssharing to determine num offspirngs for each species
    %currently using equal num offsprints
    num_equalOffspring = ceil(num_genomesRemoved / num_species);
    num_assigned_offspring = zeros(1, num_species) + num_equalOffspring;
    %crossover nur in spezies
    for j=1:num_species
        currrentSpeciesIndices = find(params.species == j);
        
        if(length(currrentSpeciesIndices) > 1)
            for k=1:num_assigned_offspring(j)
                speciesIndicesShuffled = currrentSpeciesIndices(randperm(length(currrentSpeciesIndices)));
                randomParentIndex1 = speciesIndicesShuffled(1);
                randomParentIndex2 = speciesIndicesShuffled(2);
                if(params.fitness(randomParentIndex1) <= params.fitness(randomParentIndex2))
                    parentSmallerErrorIndex = randomParentIndex1;
                    parentGreaterErrorIndex = randomParentIndex2;
                else
                    parentSmallerErrorIndex = randomParentIndex2;
                    parentGreaterErrorIndex = randomParentIndex1;
                end
                %do parents have to be removed after crossover ?
                params.connections{end+1} = crossover(params.connections{parentGreaterErrorIndex}, params.connections{parentSmallerErrorIndex}, params);
                params.nodes{end+1} = params.nodes{parentSmallerErrorIndex};
                %disp(params.connections{end})
                %disp(params.nodes{end})
            end
        end
        
    end
    
    %mutate excluding elite genomes and crossover offspring
    nonEliteGenomeIndices = setdiff(1:length(params.species), eliteIndex);
    for j=1:length(nonEliteGenomeIndices)
        if rand() < params.weightMutationRate
            params = mutateWeights(nonEliteGenomeIndices(j), params);
        end
        if rand() < params.addNodeMutationRate
            params = mutateAddNode(nonEliteGenomeIndices(j), params);
        end
        if rand() < params.addConnectionMutationRate
            params = mutateAddConnection(nonEliteGenomeIndices(j), params);
        end
        %possible alternative only one mutation each
    end
    
    %Append random mutated genomes until population is full
    num_unnasignedGenmoes = params.num_networks - length(params.nodes);
    randomGenomesInd = randi([1, length(params.nodes)], 1, num_unnasignedGenmoes);
    for j=1:length(randomGenomesInd)
        endIndex = length(params.nodes) +1;
        params.nodes{endIndex} = params.nodes{randomGenomesInd(j)};
        params.connections{endIndex} = params.connections{randomGenomesInd(j)};
        params = mutateWeights(endIndex, params);
    end
    
%     disp(min(params.fitness));
    [allElite(i),eliteId] = min(params.fitness);
    allMedian(i)= mean(params.fitness);
    
    allConnections(i)=  size(params.connections{eliteId},1);
    allNodes(i)=  size(params.nodes{eliteId},1);
    allTopologies(i) = size(params.nodes,2);
    
end
%end

function [params] = appendNode(type, netIndex, params)
params.nodeId = params.nodeId + 1;
params.nodes{netIndex} = [params.nodes{netIndex};  params.nodeId, type];
end

function [params] = addConnection(inNodeId, outNodeId, weight, state, netIndex, params)
connections = cat(1, params.connections{:});
[~, intersectConnectionsIndex] = intersect(connections(:, params.connCol_input:params.connCol_output), [inNodeId, outNodeId], 'rows');
isNewInnovation = isempty(intersectConnectionsIndex);
if(isNewInnovation)
    params.innovId = params.innovId + 1;
    connectionInnovId = params.innovId;
else
    connectionInnovId = connections(intersectConnectionsIndex, params.connCol_innovId);
end

params.connections{netIndex} = [params.connections{netIndex}; inNodeId, outNodeId, weight, state, connectionInnovId];
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

function [params] = mutateAddNode(netIndex, params)
enabledConnections = params.connections{netIndex}(params.connections{netIndex}(:,params.connCol_state) == params.conn_state_enabled,:);
if(~isempty(enabledConnections))
    randomConnectionIndex = randi([1,size(enabledConnections,1)],1);
    inNodeId = enabledConnections(randomConnectionIndex, params.connCol_input);
    outNodeId = enabledConnections(randomConnectionIndex, params.connCol_output);
    
    params = appendNode(params.node_type_hidden, netIndex, params);
    params = disableConnection(inNodeId, outNodeId, netIndex, params);
    oldweight = params.connections{netIndex}(params.connections{netIndex}(:, params.connCol_input) == inNodeId & params.connections{netIndex}(:,params.connCol_output) == outNodeId, params.connCol_weight);
    params = addConnection(inNodeId, params.nodeId, 1, params.conn_state_enabled, netIndex, params);
    params = addConnection(params.nodeId, outNodeId, oldweight, params.conn_state_enabled, netIndex, params);
end
end

function [params] = mutateWeights(netIndex, params)
for i=1:size(params.connections{netIndex},1)
    if rand() < params.singleWeightMutationRate
        params.connections{netIndex}(i,3) = params.connections{netIndex}(i,3) + normrnd(0,params.standardDeviation);
    end
    %%todo reassign weight randomly (with low popability)
end
end

function [params] = mutateAddConnection(netIndex, params)
 existingConnections = params.connections{netIndex}(:,1:2);

randomInNodeId = datasample(params.nodes{netIndex}(:,params.nodeCol_id), 1);
outNodesAlreadyConnected = existingConnections(existingConnections(:,params.connCol_input) == randomInNodeId, 2);
[nodesNotConnected, ~] = setdiff(existingConnections(:), outNodesAlreadyConnected);
%alternative setdiff(params.nodes{netIndex}(:,1), outNodesAlreadyConnected)
if( ~isempty(nodesNotConnected))
    randomOutNode = datasample(nodesNotConnected,1);
    params = addConnection(randomInNodeId, randomOutNode, randn, params.conn_state_enabled, netIndex, params);
end
end


function [offspringConnections] = crossover(parent, parentBetterFit, params)
[~, intersectParent1Idx, intersectParent2Idx] = intersect(parent(:, params.connCol_innovId),  parentBetterFit(:, params.connCol_innovId));
[~, disjointExcessIdx] = setdiff(parentBetterFit(:, params.connCol_innovId), parent(:, params.connCol_innovId));

ParentsConcatinated = [parent; parentBetterFit];
intersectIdx = [intersectParent1Idx, (intersectParent2Idx + size(parent,1))];
intersectIdxColumnSelector = randi(2,1, size(intersectIdx,1));
randomIntersectConnections = ParentsConcatinated(intersectIdx(sub2ind(size(intersectIdx), 1:size(intersectIdx,1), intersectIdxColumnSelector)),:);
parentBetterFitDisExConnections = parentBetterFit(disjointExcessIdx,:);
offspringConnections = [randomIntersectConnections; parentBetterFitDisExConnections];
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
params.species = zeros(1, size(params.nodes,2));
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
    params.species_distance = params.species_distance - 0.005;
end
if species_count > params.species_target
    params.species_distance = params.species_distance + 0.005;
end
end

function [params] = fitnessCalculation(params)
num_networks = size(params.connections,2);

%copy variables to avoid parfor broadcasting
fitness = zeros(num_networks, 1);
num_training = params.num_Training;
nodes = params.nodes;
connections = params.connections;

parfor i=1:num_networks
    
    weightMatrix = sparse(phenotyp(nodes{i},connections{i}));
    error = 0;
    
    for j=1:num_training
        currentActivation = zeros(1, max(nodes{i}(:,1)));
        currentTrainingData = params.train_data{j};
        numTrainingRows = size(currentTrainingData,1);
        for k=1:numTrainingRows
            input = [currentTrainingData(k,1), currentTrainingData(k,3)];
            netOut = [input, currentActivation(size(input,2)+1:size(currentActivation,2))] * weightMatrix;
            netOut = tanh(netOut);
            currentActivation = netOut;
            
            heartrate_pred = netOut(3);
            netError = (0.5* (currentTrainingData(k,2)-heartrate_pred)^2);
            error = error + netError;
            
        end
    end
    %params.fitness(i)=error;
    fitness(i) = error;
end

params.fitness = fitness;

end

function [params] = sharedFitness(params)

for i=1:size(params.sharedfitness,1)
    counter = 0;
    for j=1:size(params.connections,2)
        counter = counter + sharingFunction(distanceOf(params.connections{i},params.connections{j},params),params);
    end
    params.sharedfitness(i)= params.fitness(i)/counter;
end
disp(min(params.fitness));
params.fitness = params.sharedfitness;
end

function [aboveTreshold] = sharingFunction(distance, params)
aboveTreshold = 0;
if distance < params.species_distance
    aboveTreshold = 1;
end
end