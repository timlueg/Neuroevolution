clear

populationSize = 10;
mutationRate = 0.05;
crossoverRate = 0.8;
numIterations = 100;

%random population in interval (a,b)
a = -512;
b = 512;
population =  a + (b-a) .* rand(populationSize, 2);

newPopulation = zeros(size(population));

%Insert elite (last entry) and remove from population
[elite, eliteIndex] = min(egg(population));
newPopulation(populationSize,:) = population(eliteIndex,:);
population(eliteIndex,:) = [];

%tournament selection
numChildren = populationSize-1;

contender = cat(3, population(randperm(numChildren),:), population(randperm(numChildren),:));
contenderFitness = cat(3, egg(contender(:,:,1)), egg(contender(:,:,2)));

[maxFitness, maxIndex] = min(contenderFitness, [], 3); %min over pages
contender2d = reshape(permute(contender,[1 3 2]),[],size(contender,2),1); %converting 3D to 2D matrix row wise
children = contender2d((maxIndex-1) * numChildren + (1:numChildren)',:);

%crossover 
if rand() < crossoverRate
    
end


%mutate winners


%newPopulation(1:numChildren, :) = 
%egg(newPopulation)


%todo keep elite dont mutate
%mutate others

function [y] = egg(xx)
% xx has two dimensions/columns: n x 2
x1 = xx(:,1);
x2 = xx(:,2);
term1 = -(x2+47) .* sin(sqrt(abs(x2+x1./2+47)));
term2 = -x1 .* sin(sqrt(abs(x1-(x2+47))));
y = term1 + term2;
end
