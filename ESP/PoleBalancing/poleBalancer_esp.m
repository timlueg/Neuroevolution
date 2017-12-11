addpath(genpath('NE-PoleBalancing'))
num_inputNodes = 7;
num_innnerNodes = 0;
num_outputNodes = 1;
num_individuals_subpop = 30;
num_nodes_insertion = 10;

mutationRate = 0.9;
crossoverRate = 0.1;
numIterations = 300;
standardDeviation=0.03;

num_allNodes = num_innnerNodes + num_inputNodes + num_outputNodes;
num_subpops = num_innnerNodes + num_outputNodes;

%initialisierung der Population
population = zeros(num_individuals_subpop,num_allNodes,num_subpops);
for i=1:num_subpops
    population(:,:,i) = normrnd(0, 0.5, num_individuals_subpop, num_allNodes);
end

sumEliteFitness = zeros(1, numIterations);
sumMeanFitness = zeros(1,numIterations);

num_steps_history = zeros(1, numIterations*num_subpops*num_individuals_subpop);
loopIndex = 0;

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
            
            loopIndex = loopIndex +1;
            [netFitness, num_steps_history(loopIndex) ] = run_poleBalancer_esp(weightMatrix, currentActivation);
            for n=1:num_subpops
                population_fitness(population_perm_selector(m,n),n) = population_fitness(population_perm_selector(m,n),n) + (netFitness / num_nodes_insertion);
            end
            
        end
        
    end
    
    if mod(l,10) == 0
        disp(['max Steps achieved: ' int2str(max(num_steps_history))]);
        disp(mean(elite_fitness));
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %ab hier genetischer Algorithmus fuer die Subpopulationen.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [elite_fitness, eliteIndex] = max(population_fitness,[],1);
    for s=1:num_subpops
        population_new = zeros(num_individuals_subpop, num_allNodes);
        %elitism
        population_new(1,:) = population(eliteIndex(s),:,s);
        
        
        %tournament selection with 2 parents
        %todo prevent to many duplicate selections
        for o=2:num_individuals_subpop
            contenderIndex1 = o;%floor(1 + (num_individuals_subpop-1) * rand(1));
            contenderIndex2 = floor(1 + (num_individuals_subpop-1) * rand(1));
            if(population_fitness(contenderIndex1,s) < population_fitness(contenderIndex2,s))
                population_new(o,:)= population(contenderIndex2,:,s);
            else
                population_new(o,:)= population(contenderIndex1,:,s);
            end
            
        end
        population(:,:,s)=population_new;
        
        % uniform corssover
        for o=2:num_individuals_subpop-1
            if rand() < crossoverRate
                for p=1:num_allNodes-1
                    if rand < 0.5
                        %selects 2 parents,flips nodes weight
                        parent1 = o;
                        parent2 = floor(1 + (num_individuals_subpop-1) * rand(1));
                        population_new(parent1:parent2,p) = flip(population_new(parent1:parent2,p));
                    end
                end
            end
        end
        
        population(:,:,s)=population_new;
        
        %mutation
        num_children = num_individuals_subpop -1; %without elite
        mutationSelector = rand(num_children,1) <= mutationRate;
        
        population(2:num_individuals_subpop, :, s) = population(2:num_individuals_subpop, :, s) + (repmat(mutationSelector,1,num_allNodes) .* normrnd(0,standardDeviation, [num_children, num_allNodes]));
        
        
    end
    
    sumEliteFitness(l) = sum(elite_fitness);
    sumMeanFitness(l)  = sum((mean(population_fitness, 1)));
end