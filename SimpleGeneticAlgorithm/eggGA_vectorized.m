x=-500:5:500; y=x;
[X,Y] = ndgrid(x,y);
Z = egg([X(:),Y(:)]);
Z = reshape(Z,size(X,1),size(X,2));
%surf(X,Y,Z);

populationSize = 10;
mutationRate = 0.05;
crossoverRate = 0.8;
numIterations = 100;

%random population in interval (a,b)
a = -512;
b = 512;
population =  a + (b-a) .* rand(populationSize, 2);

newPopulation = zeros(size(population));

%tournament selection
contender(:,:,1) = population(randperm(populationSize),:);
contender(:,:,2) = population(randperm(populationSize),:);
contenderFitness(:,:,1) = egg(contender(:,:,1));
contenderFitness(:,:,2) = egg(contender(:,:,2))

[maxFitness, maxIndex] = max(contenderFitness, [], 3);
[m,n,k] = size(contender);
contender2d = reshape(permute(contender,[1 3 2]),[],size(contender,2),1) %converting 3D to 2D matrix row wise
winner = contender2d((maxIndex-1) * populationSize + (1:populationSize)',:);

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
