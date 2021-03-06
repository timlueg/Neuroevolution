function [history,fitnessHistory,populationSize,numIterations] = eggGa()
x=-500:5:500; y=x;
[X,Y] = ndgrid(x,y);
Z = egg([X(:),Y(:)]);
Z = reshape(Z,size(X,1),size(X,2));
%surf(X,Y,Z);

populationSize = 100;
mutationRate = 1;
crossoverRate = 0.8;
numIterations = 100;
dimension=2;
history=zeros(numIterations,populationSize,dimension);
fitnessHistory=zeros(numIterations,populationSize);
standardDeviation=1;

%random population in interval (a,b)
a = -512;
b = 512;
population =  a + (b-a) .* rand(populationSize, dimension);

newPopulation = zeros(size(population));
eliteDevelopment=(zeros(1,numIterations));

for j=1:numIterations
    populationFitness = egg(population);
    
    %copy and remove elite
    [elite, eliteIndex] = min(populationFitness);
    newPopulation(1,:) = population(eliteIndex,:);
    population(eliteIndex,:) = [];
    populationFitness(eliteIndex,:) = [];
    
    %tournament selection with 2 parents
    for i=1:populationSize-1
        contenderIndex1 = floor(1 + (populationSize-1) * rand(1));
        contenderIndex2 = floor(1 + (populationSize-1) * rand(1));
        if(populationFitness(contenderIndex1) > populationFitness(contenderIndex2))
            newPopulation(i+1,:)= population(contenderIndex2,:);
        else
            newPopulation(i+1,:)= population(contenderIndex1,:);
        end
        
    end
    population = newPopulation;
    
    %crossover
    for i=1:populationSize-1
        if rand()< crossoverRate
            contenderIndex= zeros(dimension,1);
            for k=1:dimension
                contenderIndex(k) = floor((populationSize-1) * rand(1)+1);
            end
            for k=1:dimension
                newPopulation(i+1,k)=population(contenderIndex(k),k);
               
            end
        end
    end
    
    population = newPopulation;
    
    %mutation
    for i=2:populationSize
        
        if rand()<mutationRate
            for k=1:dimension
                population(i,k) = population(i,k)+ normrnd(0,standardDeviation);
            end
        end
    end
    fitnessHistory(j,:)=egg(population(:,:))';
    for k=1:dimension
        history(j,:,k)=population(:,k)';
        
    end
    eliteDevelopment(j)= egg(population(1,:));
    
end
disp(egg(population));
%disp(population(1,:));
end

function [y] = egg(xx)
% xx has two dimensions/columns: n x 2
x1 = xx(:,1);
x2 = xx(:,2);
term1 = -(x2+47) .* sin(sqrt(abs(x2+x1./2+47)));
term2 = -x1 .* sin(sqrt(abs(x1-(x2+47))));
y = term1 + term2;
end
