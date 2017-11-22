num_inputNodes = 2;
num_innnerNodes = 3;
num_outputNodes = 1;
SubpopulationSize = 20;
count_nodes_insertion =10;

num_allNodes = num_innnerNodes + num_inputNodes + num_outputNodes;
num_of_Subpop = num_innnerNodes + num_outputNodes;

%gewichteMatrix = zeros(num_allNodes,num_of_Subpop);
population = zeros(SubpopulationSize,num_allNodes,num_of_Subpop);

%zusammenstellung der Population
for i=1:num_of_Subpop
    for j=1:SubpopulationSize
        population(j,:,i) = rand(1,num_allNodes);
    end
end

N = SubpopulationSize;
perm{count_nodes_insertion} = [];
for i=1:count_nodes_insertion
    p = randperm(N);
    perm{j} = [perm{j} p];
end




