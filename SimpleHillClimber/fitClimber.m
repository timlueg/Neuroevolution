function [solution,xValues,yValues] = fitClimber()
%UNTITLED4 Summary of this function goes here
% Detailed explanation goes here
fit = @(x) (x>1).*(2.*x-2) + (x<=0.5).*8.*x + ((x>0.5).*(x<=1)).*(-8.*x + 8);

numIterations = 100;
dimensionen=1;

xValues = zeros(dimensionen,numIterations);
yValues = zeros(dimensionen,numIterations);
current=zeros(1,dimensionen);

%random value in interval (a,b)
a = 0;
b = 2;
for i=1:dimensionen
    current(i) = a + (b-a) .* rand();
end
for i=1:numIterations
    solutionRange = [0;0.1;-0.1] + current(1,:);
    [maxfit, indexMax] = max(fit(solutionRange));
    current(1,:) = solutionRange(indexMax,:);
    
    xValues(:,i) = current(1,:)';
    yValues(i) = maxfit;
end

solution=xValues(:,numIterations);

end
function [y] = egg(xx)
% xx has two dimensions/columns: n x 2
x1 = xx(:,1);
x2 = xx(:,2);
term1 = -(x2+47) .* sin(sqrt(abs(x2+x1./2+47)));
term2 = -x1 .* sin(sqrt(abs(x1-(x2+47))));
y = term1 + term2;
end