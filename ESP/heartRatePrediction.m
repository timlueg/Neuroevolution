load ('trainingData.mat','tdata')

training_data = {tdata{1:10}};
test_data = {tdata{10:12}};

numTraining = size(training_data,2);
numTest = size(test_data,2);

num_inputNodes = 2;
num_innnerNodes = 3;
num_outputNodes = 1;
SubpopulationSize = 6;
num_nodes_insertion =10;

num_allNodes = num_innnerNodes + num_inputNodes + num_outputNodes;
num_of_Subpop = num_innnerNodes + num_outputNodes;

%gewichteMatrix = zeros(num_allNodes,num_of_Subpop);
population = zeros(SubpopulationSize,num_allNodes,num_of_Subpop);
population_fitness = zeros(SubpopulationSize,1,num_of_Subpop);

%zusammenstellung der Population
for i=1:num_of_Subpop
    for j=1:SubpopulationSize
        population(j,:,i) = rand(1,num_allNodes);
    end
end


for i=1:numTraining
    
    N = SubpopulationSize;
    %population_perm = zeros(SubpopulationSize * num_nodes_insertion ,num_allNodes,num_of_Subpop);
    for j=1:num_nodes_insertion
        for k=1:num_of_Subpop
            p = randperm(N);
            
            for l=1:SubpopulationSize
            
            %population_perm(1+(j-1)*SubpopulationSize:i*SubpopulationSize,:,k) = population(p,:,k);
            %combine along thid dimension 
            selected_weights = reshape(permute(population(p,:,k),[2,1,3]),size(population(p,:,k),2),[])';
            startInput = [training_data{numTraining}(1,1),training_data{numTraining}(1,3), 1, 1, 1];
            for m=1:size(training_data{numTraining},1)
                startInput * selected_weights';
            end
            
            end


        end
    end

end

function [error]= fitness(target,out)
error=0.5* (target-out)^2;
end
