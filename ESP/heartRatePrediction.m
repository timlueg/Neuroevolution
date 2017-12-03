load ('trainingData.mat','tdata')

training_data = {tdata{1:10}};
test_data = {tdata{10:12}};

numTraining = size(training_data,2);
numTest = size(test_data,2);

num_inputNodes = 2;
num_innnerNodes = 3;
num_outputNodes = 1;
num_individuals_subpop = 7;
num_nodes_insertion = 10;

num_allNodes = num_innnerNodes + num_inputNodes + num_outputNodes;
num_subpops = num_innnerNodes + num_outputNodes;

%gewichteMatrix = zeros(num_allNodes,num_of_Subpop);
population = zeros(num_individuals_subpop,num_allNodes,num_subpops);
population_fitness = zeros(num_individuals_subpop,1,num_subpops);

%zusammenstellung der Population
for i=1:num_subpops
    for j=1:num_individuals_subpop
        population(j,:,i) = rand(1,num_allNodes);
    end
end


% for i=1:numTraining
%     
%     %population_perm = zeros(SubpopulationSize * num_nodes_insertion ,num_allNodes,num_of_Subpop);
%     for j=1:num_nodes_insertion
%         for k=1:num_subpops
%             p = randperm(N);
%             
%             for l=1:num_individuals_subpop
%             
%             %population_perm(1+(j-1)*SubpopulationSize:i*SubpopulationSize,:,k) = population(p,:,k);
%             %combine along thid dimension 
%             %selected_weights = reshape(permute(population(p,:,k),[2,1,3]),size(population(p,:,k),2),[])';
%             %population_shuffled
%             %selected_individuals = 
%             startInput = [training_data{numTraining}(1,1),training_data{numTraining}(1,3), 1, 1, 1];
%             for m=1:size(training_data{numTraining},1)
%                 startInput * selected_weights';
%             end
%             
%             end
% 
% 
%         end
%     end
% 
% end

for i=1:numTraining
    
    population_fitness = zeros(num_individuals_subpop, num_subpops);

    numTrainingRows = size(training_data{i},1);
    for r=1:numTrainingRows
        
        
        input = [training_data{i}(r,1),training_data{i}(r,3)];
        population_perm = population;
        population_perm_selector = zeros(num_individuals_subpop, num_subpops);
        
        for j=1:num_subpops
            population_perm_selector(:, j) = randperm(num_individuals_subpop);
            population_perm(:,:,j) = population_perm(population_perm_selector(:,j), :, j);
        end
        
        for k=1:num_nodes_insertion
            
            currentActivation = ones(1, num_innnerNodes + num_outputNodes);
            for m=1:num_individuals_subpop
                weightMatrix = reshape(permute(population_perm(m,:,:),[2,1,3]),size(population_perm(m,:,:),2),[])'; %combine along 3rd dim
                netOut = tanh([input, currentActivation] * weightMatrix');
                currentActivation = netOut;
            end
            
        end
        
         %calcuate fitness and do evolution here
        
    end
    
end

function [error]= fitness(target,out)
error=0.5* (target-out)^2;
end




























