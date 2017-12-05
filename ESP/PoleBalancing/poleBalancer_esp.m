addpath(genpath('NE-PoleBalancing'))

num_inputNodes = 7;
num_innnerNodes = 4;
num_outputNodes = 1;
num_individuals_subpop = 7;
num_nodes_insertion = 10;

mutationRate = 0.8;
crossoverRate = 0.5;
numIterations = 200;
standardDeviation=0.02;

num_allNodes = num_innnerNodes + num_inputNodes + num_outputNodes;
num_subpops = num_innnerNodes + num_outputNodes;

%gewichteMatrix = zeros(num_allNodes,num_of_Subpop);
population = zeros(num_individuals_subpop,num_allNodes,num_subpops);
%zusammenstellung der Population
for i=1:num_subpops
    for j=1:num_individuals_subpop
        population(j,:,i) = rand(1,num_allNodes);
    end
end

sumEliteFitness = zeros(1, numIterations);

for l=1:numIterations
    
    population_fitness = zeros(num_individuals_subpop, num_subpops);
    
    population_perm = population;
    population_perm_selector = zeros(num_individuals_subpop, num_subpops);
    
    
    for k=1:num_nodes_insertion
        
        for j=1:num_subpops
            population_perm_selector(:, j) = randperm(num_individuals_subpop);
            population_perm(:,:,j) = population_perm(population_perm_selector(:,j), :, j);
        end
        
        for m=1:num_individuals_subpop
            currentActivation = zeros(1, num_innnerNodes + num_outputNodes);
            weightMatrix = reshape(permute(population_perm(m,:,:),[2,1,3]),size(population_perm(m,:,:),2),[])'; %combine along 3rd dim
            
            %for r=1:100 %anzahl simulationsdurchläufe mit ausgewhaelten knoten
                netFitness = run_poleBalancer_esp(weightMatrix, currentActivation);
                for n=1:num_subpops
                    population_fitness(population_perm_selector(m,n),n) = population_fitness(population_perm_selector(m,n),n) + netFitness;
                end
            %end
        end
        
    end
    

        
        %population_fitness = population_fitness./10;
        %population_fitness = population_fitness ./ size(tdata{i},1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %ab hier genetischer Algorithmus fuer die Subpopulationen.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        [elite_fitness, eliteIndex] = max(population_fitness,[],1);
        for s=1:num_subpops
            population_new = zeros(num_individuals_subpop, num_allNodes);
            %elitism
            population_new(1,:) = population(eliteIndex(s),:,s);
            
            
            %tournament selection with 2 parents
            for o=1:num_individuals_subpop-1
                contenderIndex1 = floor(1 + (num_individuals_subpop-1) * rand(1));
                contenderIndex2 = floor(1 + (num_individuals_subpop-1) * rand(1));
                if(population_fitness(contenderIndex1,s) < population_fitness(contenderIndex2,s))
                    population_new(o+1,:)= population(contenderIndex2,:,s);
                else
                    population_new(o+1,:)= population(contenderIndex1,:,s);
                end
                
            end
            population(:,:,s)=population_new;
            
            %crossover
            for o=1:num_individuals_subpop-1
                if rand()< crossoverRate
                    contenderIndex= zeros(num_allNodes,1);
                    for k=1:num_allNodes
                        contenderIndex(k) = floor((num_individuals_subpop-1) * rand(1)+1);
                    end
                    for k=1:num_allNodes
                        population_new(o+1,k)=population(contenderIndex(k),k);
                        
                    end
                end
            end
            
            population(:,:,s)=population_new;
            
            %mutation
            for o=2:num_individuals_subpop
                
                if rand()<mutationRate
                    for k=1:num_allNodes
                        population(o,k,s) = population(o,k,s)+ normrnd(0,standardDeviation);
                    end
                end
            end
            
        end
    
    disp(sum(elite_fitness));
    %disp(population_fitness);
    sumEliteFitness(l) = sum(elite_fitness);
    
end