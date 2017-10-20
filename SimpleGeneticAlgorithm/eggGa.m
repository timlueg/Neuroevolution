x=-500:5:500; y=x;
[X,Y] = ndgrid(x,y);
Z = egg([X(:),Y(:)]);
Z = reshape(Z,size(X,1),size(X,2));
%surf(X,Y,Z);

populationSize = 100;
mutationRate = 0.05;
crossoverRate = 0.8;
numIterations = 100;

%random population in interval (a,b)
a = -512;
b = 512;
population =  a + (b-a) .* rand(populationSize, 2);

newPopulation = zeros(size(population));
eliteDevelopment=(zeros(1,populationSize));

for j=1:numIterations
    populationFitness = egg(population);
    
    %copy and remove elite
    [elite, eliteIndex] = min(populationFitness);
    newPopulation(1,:) = population(eliteIndex,:);
    population(eliteIndex,:) = [];
    populationFitness(eliteIndex,:) = [];
    
    %tournament selection with 2 parents
    for i=1:populationSize-1
        contenderIndex1 = floor(1 + (99) * rand(1));
        contenderIndex2 = floor(1 + (99) * rand(1));
        if(populationFitness(contenderIndex1) > populationFitness(contenderIndex2))
            newPopulation(i+1,:)= population(contenderIndex2,:);
        else
            newPopulation(i+1,:)= population(contenderIndex1,:);
        end
        
    end
    population = newPopulation;
    
    %crossover
    for i=2:populationSize
        if rand()< crossoverRate
            contenderIndex1 = floor(100 * rand(1)+1);
            contenderIndex2 = floor(100 * rand(1)+1);
            newPopulation(i,1)=population(contenderIndex1,1);
            newPopulation(i,2)=population(contenderIndex2,2);
        end
    end
    
    population = newPopulation;
    
    %mutation
    for i=2:populationSize
        if rand()<mutationRate
            population(i,floor(2.*rand()+1)) =  a + (b-a) * rand();
        end
    end
    

   eliteDevelopment(j)= egg(population(1,:));
end
disp(egg(population(1,:)));
disp(population(1,:));


function [y] = egg(xx)
% xx has two dimensions/columns: n x 2
x1 = xx(:,1);
x2 = xx(:,2);
term1 = -(x2+47) .* sin(sqrt(abs(x2+x1./2+47)));
term2 = -x1 .* sin(sqrt(abs(x1-(x2+47))));
y = term1 + term2;
end
