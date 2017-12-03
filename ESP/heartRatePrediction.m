load ('trainingData.mat','tdata')

%todo normalize dataset
%todo correct permutation or fiteness matrix

%normalize dataset
%for i=1:size(tdata,2)
%    tdata{i} = mapminmax(tdata{i});
%end

train_data = {tdata{1:10}};
test_data = {tdata{10:12}};

numTraining = size(train_data,2);
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
    
    numTrainingRows = size(train_data{i},1);
    
    population_perm = population;
    population_perm_selector = zeros(num_individuals_subpop, num_subpops);
    
    
    for k=1:num_nodes_insertion
        
        for j=1:num_subpops
        population_perm_selector(:, j) = randperm(num_individuals_subpop);
        population_perm(:,:,j) = population_perm(population_perm_selector(:,j), :, j);
        end
        
        for m=1:num_individuals_subpop
            currentActivation = ones(1, num_innnerNodes + num_outputNodes);
             weightMatrix = reshape(permute(population_perm(m,:,:),[2,1,3]),size(population_perm(m,:,:),2),[])'; %combine along 3rd dim
            for r=1:numTrainingRows
                input = [train_data{i}(r,1),train_data{i}(r,3)];
                netOut = [input, currentActivation] * weightMatrix';
                %netOut = tanh(netOut);
                currentActivation = netOut;
                
                heartrate_pred = netOut(size(currentActivation,2));
                netFitness = fitness(train_data{i}(r,2), heartrate_pred);
                for n=1:num_subpops
                    population_fitness(population_perm_selector(m,n),n) = population_fitness(population_perm_selector(m,n),n) + netFitness;
                end
                
            end
            
            
        end
        
    end
    
    population_fitness = population_fitness./10;
    
    for s=1:num_subpops
        population_new = zeros(num_individuals_subpop, num_allNodes);
    end
    
    %calcuate fitness and do evolution here
    
    
end

function [error]= fitness(target,out)
error=1/ (0.5* (target-out)^2);
end




























