%function [params] = neat_network(isNextSimulation)

if(~exist('params', 'var'))
    params = initialize();
    
    if(init)
        isTraining = false;
        if(experimentType == 'learningRates')
            experiment_learingRates = [0.0002, 0.002, 0.02, 0.2, 0.1];
            experiment_weightResetRates = [0.98, 0.98, 0.98, 0.98, 0.98];
        end
        
        logEliteFitness = cell(num_experiments, 1);
        for i=1:num_experiments
            logEliteFitness{i} = zeros(num_iterations, num_runs);
        end
        logEliteFitnessCurrent = [];
        logEliteNumNodes = [];
        logEliteNumConnections = [];
        
        isVisualization = false;
        init = false;
    end
    
    if(experimentType == 'learningRates')
        params.standardDeviation = experiment_learingRates(experiment);
        params.singleWeightMutationRate = experiment_weightResetRates(experiment);
    end
    
end

if(isTraining)
    params.fitness = marioFitness;
    [maxfitness,indexMaxFitness] = max(params.fitness);
    %logEliteFitnessCurrent = [logEliteFitnessCurrent, maxfitness ];
    
    %logEliteNumNodes = [logEliteNumNodes,length(params.nodes{indexMaxFitness})];
    %logEliteNumConnections = [logEliteNumConnections, size(params.connections{indexMaxFitness}(params.connections{indexMaxFitness}(:,params.connCol_state)== params.conn_state_enabled,:),1)];
    
    logEliteFitness{experiment}(iteration, experiment_run) = maxfitness;
    
    params = train(params);
end

if(isVisualization)
   figure(1);
   cla;
   hold on;
   legend();
   for i=1:num_experiments
       plot(mean(logEliteFitness{i}, 2));
   end
   line([1,size(logEliteFitness{1},1)],[4096,4096],'Color','k');
   xlabel('Iteration');
   ylabel('Fitness');
      legend('Tr = 0,2 LR = 0,0002','Tr = 0,2 LR = 0,002','Tr = 0,2 LR = 0,02','Tr = 0,2 LR = 0,2''Tr = 0,2 LR = 0,1','Level geschafft')
   
   hold off;
   figure(2);
   cla;
   boxplotdata=[];
   for i=1:num_experiments
      boxplotdata=[boxplotdata;logEliteFitness{i}(500,:)];
       
   end
   boxplot(boxplotdata);
   
%    figure(2);
%    cla;
%    hold on;
%    plot(logEliteNumNodes);
%    plot(logMeanNumNodes);
%    xlabel('Generationen');
%    ylabel('Knotenzahl');
%    legend('Elite');
%    hold off;
%    
%    figure(3);
%    cla;
%    hold on;
%    plot(logEliteNumConnections);
%    xlabel('Generationen');
%    ylabel('Kantenzahl');
%    legend('Elite');
%    hold off;
end

%end

function [params] = initialize() 
%Hyperparameter 
params.weightMutationRate = 0.8;
params.singleWeightMutationRate = 0.98;
params.addNodeMutationRate = 0.02;
params.addConnectionMutationRate = 0.08;
params.disableConnectionMutationRate = 0.08;
params.standardDeviation = 0.002;
params.standardDeviationInit = 0.2;
params.genomeRemovalRate = 0.3;

%network structure
params.num_input = 121;
params.num_output = 4;
params.num_networks = 32;

%distance parameter
params.c1 = 1;
params.c2 = 1;
params.c3 = 0.4;

%species parameter
params.species_target = 4;
params.species_distance = 0.01;

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
        params = addConnection(aktuelleKnoten + j, aktuelleKnoten + params.num_input + k, normrnd(0, params.standardDeviationInit), params.conn_state_enabled, 1, params);
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
%array2table(params.nodes{1}, 'VariableNames', params.node_columnNames)
%array2table(params.connections{1}, 'VariableNames', params.connection_columnNames)

end

function [params] = train(params)
    params = defineSpecies(params);
    %disp(params.species);
    %disp(params.species_distance);
    %remove less fit genes
    [~, sortIndex] = sort(params.fitness, 'descend');
    num_genomesRemoved = floor(size(params.connections,2) * params.genomeRemovalRate);
    num_genomesSelected = floor(size(params.connections,2) * (1-params.genomeRemovalRate));
    sortIndex = sortIndex(1:num_genomesSelected);
    params.connections = params.connections(sortIndex);
    params.nodes = params.nodes(sortIndex);
    params.species = params.species(sortIndex);
    params.fitness = params.fitness(sortIndex);
    %todo veraendern durch Mutation/Crossover innerhalb einer species bis Groe�e wieder aufgefuellt
    
    %params = sharedFitness(params);
    
    %index of elite for each species (with >=5 networks)
    num_species = max(params.species);
    %allSpezies(i) = num_species;
    %allDistance(i) = params.species_distance;
    num_genomesInSpecies = zeros(1, num_species);
    for j=1:length(params.species)
        num_genomesInSpecies(params.species(j))= num_genomesInSpecies(params.species(j)) + 1;
    end
    grosseSpecies = find(num_genomesInSpecies >= 3);
    eliteIndex = zeros(1,length(grosseSpecies));
    if(~isempty(grosseSpecies))
        for j=1:length(grosseSpecies)
            maxValue=-Inf;
            maxIndex=0;
            for k=1:length(params.fitness)
                if params.species(k)== grosseSpecies(j)
                    if params.fitness(k) > maxValue
                        maxValue = params.fitness(k);
                        maxIndex = k;
                    end
                end
            end
            eliteIndex(j) = maxIndex;
        end
    end
    
    
    %Anzahl an offspring abhängig von Anteil an gesamt fitness
    fitness_per_species = zeros(1,num_species);
    for j=1:length(params.species)
        fitness_per_species(params.species(j)) = fitness_per_species(params.species(j)) + params.fitness(j); 
    end
    fitness_per_species_percent = zeros(1,num_species);
    for j=1:size(fitness_per_species,2)
        fitness_per_species_percent(j) = 1-(fitness_per_species(j)/sum(fitness_per_species)); 
    end
    fitness_per_species_percent = fitness_per_species_percent/num_species;
    
    %disp(sum(fitness_per_species_percent));
    
    %currently using equal num offsprints
    %num_equalOffspring = ceil(num_genomesRemoved / num_species);
    %num_assigned_offspring = zeros(1, num_species) + num_equalOffspring;
    
    
    num_assigned_offspring = round(num_genomesRemoved*fitness_per_species_percent);
    %crossover nur in spezies
    for j=1:num_species
        currrentSpeciesIndices = find(params.species == j);
        
        if(length(currrentSpeciesIndices) > 1)
            for k=1:num_assigned_offspring(j)
                speciesIndicesShuffled = currrentSpeciesIndices(randperm(length(currrentSpeciesIndices)));
                randomParentIndex1 = speciesIndicesShuffled(1);
                randomParentIndex2 = speciesIndicesShuffled(2);
                if(params.fitness(randomParentIndex1) >= params.fitness(randomParentIndex2))
                    parentHigherFitnessIndex = randomParentIndex1;
                    parentLowerFitnessIndex = randomParentIndex2;
                else
                    parentHigherFitnessIndex = randomParentIndex2;
                    parentLowerFitnessIndex = randomParentIndex1;
                end
                %do parents have to be removed after crossover ?
                params.connections{end+1} = crossover(params.connections{parentLowerFitnessIndex}, params.connections{parentHigherFitnessIndex}, params);
                params.nodes{end+1} = params.nodes{parentHigherFitnessIndex};
            end
        end
        
    end
    
    %mutate excluding elite genomes and crossover offspring
    nonEliteGenomeIndices = setdiff(1:length(params.species), eliteIndex);
    for j=1:length(nonEliteGenomeIndices)
        muationSelection = sum(rand >= cumsum([0,params.weightMutationRate, params.addNodeMutationRate, params.addConnectionMutationRate, params.disableConnectionMutationRate]));
        if muationSelection == 1
            params = mutateWeights(nonEliteGenomeIndices(j), params);
        end
        if muationSelection == 2
            params = mutateAddNode(nonEliteGenomeIndices(j), params);
        end
        if muationSelection == 3
            params = mutateAddConnection(nonEliteGenomeIndices(j), params);
        end
        if muationSelection == 4
            params = mutateDisableConnection(nonEliteGenomeIndices(j), params);
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

end

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

function [params] = mutateDisableConnection(netIndex, params)
enabledConnectionIndices = params.connections{netIndex}(:,params.connCol_state)== params.conn_state_enabled;
[~, randomEnabledConnIndex] = datasample(find(enabledConnectionIndices), 1);
params.connections{netIndex}(randomEnabledConnIndex, params.connCol_state) = ~params.conn_state_enabled;
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
connections = params.connections{netIndex};

weightMuationSelector = (rand(size(params.connections{netIndex},1),1) < params.singleWeightMutationRate);
%weight mutation
connections(:,params.connCol_weight) = connections(:,params.connCol_weight) + (weightMuationSelector .* normrnd(0,params.standardDeviation, [size(connections,1),1]));
%reset the remaining weights randomly
connections(~weightMuationSelector,params.connCol_weight) = normrnd(0,params.standardDeviationInit, [size(connections(~weightMuationSelector,params.connCol_weight),1),1]);

params.connections{netIndex} = connections;
end

function [params] = mutateAddConnection(netIndex, params)
 existingConnections = params.connections{netIndex}(:,1:2);

randomInNodeId = datasample(params.nodes{netIndex}(:,params.nodeCol_id), 1);
outNodesAlreadyConnected = existingConnections(existingConnections(:,params.connCol_input) == randomInNodeId, 2);
[nodesNotConnected, ~] = setdiff(existingConnections(:), outNodesAlreadyConnected);
%alternative setdiff(params.nodes{netIndex}(:,1), outNodesAlreadyConnected)
if( ~isempty(nodesNotConnected))
    randomOutNode = datasample(nodesNotConnected,1);
    params = addConnection(randomInNodeId, randomOutNode, normrnd(0, params.standardDeviationInit), params.conn_state_enabled, netIndex, params);
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

function [distance] = distanceOf(parent1, parent2, params)
[intersectInnovIds, matchingParent1Idx, matchingParent2Idx] = intersect(parent1(:, params.connCol_innovId),  parent2(:, params.connCol_innovId));
num_matching = length(intersectInnovIds);

%[disExcInnovIdParent1, ~] = setdiff(parent1(:, params.connCol_innovId), parent2(:, params.connCol_innovId));
%[disExcInnovIdParent2, ~] = setdiff(parent2(:, params.connCol_innovId), parent1(:, params.connCol_innovId));

disExcInnovIdParent1 = parent1(~ismember(parent1(:, params.connCol_innovId), parent2(:, params.connCol_innovId)),params.connCol_innovId);
disExcInnovIdParent2 = parent2(~ismember(parent2(:, params.connCol_innovId), parent1(:, params.connCol_innovId)),params.connCol_innovId);

if(isempty(disExcInnovIdParent1)), disExcInnovIdParent1 = 0; end
if(isempty(disExcInnovIdParent2)), disExcInnovIdParent2 = 0; end

if(max(disExcInnovIdParent1) > max(disExcInnovIdParent2))
    num_excess = length(disExcInnovIdParent1( disExcInnovIdParent1 > max(disExcInnovIdParent2)) );
    num_disjoint = size(parent1, 1) - num_matching - num_excess;
elseif (max(disExcInnovIdParent1) < max(disExcInnovIdParent2))
    num_excess = length(disExcInnovIdParent2( disExcInnovIdParent2 > max(disExcInnovIdParent1)) );
    num_disjoint = size(parent2, 1) - num_matching - num_excess;
else
    num_excess = 0;
    num_disjoint = size(parent1, 1) - num_matching - num_excess;
end

avg_weight_Diff = sum(abs(parent1(matchingParent1Idx, params.connCol_weight) - parent2(matchingParent2Idx, params.connCol_weight)));
avg_weight_Diff = avg_weight_Diff / num_matching;

if(size(parent1,1) > size(parent2,1))
    N = size(parent1,1);
else
    N = size(parent2,1);
end

if(N < 20), N = 1; end

distance = ((params.c1 * num_excess)/N) + ((params.c2 * num_disjoint)/ N) + (params.c3 * avg_weight_Diff);

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
    params.species_distance = params.species_distance - 0.0001;
end
if species_count > params.species_target
    params.species_distance = params.species_distance + 0.0001;
end
end

function [params] = sharedFitness(params)
params.sharedfitness = zeros(1, length(params.fitness));
for i=1:length(params.sharedfitness)
    counter = 0;
    for j=1:size(params.connections,2)
        counter = counter + sharingFunction(distanceOf(params.connections{i},params.connections{j},params),params);
    end
    params.sharedfitness(i)= params.fitness(i)/counter;
end
%disp(max(params.fitness));
params.fitness = params.sharedfitness;
%disp(max(params.fitness));
end

function [aboveTreshold] = sharingFunction(distance, params)
aboveTreshold = 0;
if distance < params.species_distance
    aboveTreshold = 1;
end
end