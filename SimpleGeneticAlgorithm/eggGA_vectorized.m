function [history,fitnessHistory,populationSize,numIterations] = eggGA_vectorized()
numIterations = 100;
populationSize = 100;
crossoverRate = 0.8;
mutationRate = 1/populationSize;
mutationStrength = 1;

%variables to store history
history=zeros(numIterations,populationSize,2);
fitnessHistory=zeros(numIterations,populationSize);

%random population in interval (a,b)
a = -512;
b = 512;
population =  a + (b-a) .* rand(populationSize, 2);
newPopulation = zeros(size(population));

for i=1:numIterations

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
crossoverSelector = rand(numChildren,1) <= crossoverRate;
crossoverSelected =  children(any(crossoverSelector,2),:);
crossoverUnchanged = children(any(1 - crossoverSelector,2),:);
crossoverSelected(:,2) = crossoverSelected(randperm(size(crossoverSelected,1)),2); %permutate 2. column
children = cat(1, crossoverSelected, crossoverUnchanged);

%mutate children 
standardDeviation = mutationStrength;
mutationSelector = rand(numChildren,1) <= mutationRate;
children =  children + (repmat(mutationSelector,1,2) .* normrnd(0,standardDeviation, [numChildren,2]));

%insert children
newPopulation(1:numChildren, :) = children;



population = newPopulation;

%save history for visualization
fitnessHistory(i,:) = egg(population(:,:));
history(i,:,1)=population(:,1);
history(i,:,2)=population(:,2);

end

%egg(newPopulation)
disp(elite)
disp(population(eliteIndex,:));

end



%egg([522.1469,413.3025]) smaller than global minimum ???

function [y] = egg(xx)
% xx has two dimensions/columns: n x 2
x1 = xx(:,1);
x2 = xx(:,2);
term1 = -(x2+47) .* sin(sqrt(abs(x2+x1./2+47)));
term2 = -x1 .* sin(sqrt(abs(x1-(x2+47))));
y = term1 + term2;
end
