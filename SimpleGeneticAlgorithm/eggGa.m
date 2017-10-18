x=-500:5:500; y=x;
[X,Y] = ndgrid(x,y);
Z = egg([X(:),Y(:)]);
Z = reshape(Z,size(X,1),size(X,2));
%surf(X,Y,Z);

populationSize = 100;
mutationRate = 0.05;
corssoverRate = 0.8;
numIterations = 100;

%random population in interval (a,b)
a = -512;
b = 512;
population =  a + (b-a) .* rand(populationSize, 2);

newPopulation = zeros(size(population));

populationFitness = egg(population);

%copy and remove elite
[elite, eliteIndex] = min(populationFitness);
newPopulation(1,:) = population(eliteIndex,:);
population(eliteIndex,:) = [];
populationFitness(eliteIndex,:) = [];


for i=1:populationSize-1
    contenderIndex1 = floor(1 + (99-1) .* rand(1));
    contenderIndex2 = floor(1 + (99-1) .* rand(1));
    if(populationFitness(contenderIndex1) <= populationFitness(contenderIndex2))
        
    end
    
end

function [y] = egg(xx)
% xx has two dimensions/columns: n x 2
x1 = xx(:,1);
x2 = xx(:,2);
term1 = -(x2+47) .* sin(sqrt(abs(x2+x1./2+47)));
term2 = -x1 .* sin(sqrt(abs(x1-(x2+47))));
y = term1 + term2;
end
