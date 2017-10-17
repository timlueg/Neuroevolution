function [solution,xValues,yValues] = fitClimber()
%UNTITLED4 Summary of this function goes here
% Detailed explanation goes here
fit = @(x) (x>1).*(2.*x-2) + (x<=0.5).*8.*x + ((x>0.5).*(x<=1)).*(-8.*x + 8);

numIterations = 100;

xValues = zeros(1,numIterations);
yValues = zeros(1,numIterations);

%random value in interval (a,b)
a = 0;
b = 2;
currentX = a + (b-a) .* rand();

for i=1:numIterations
    solutionRange = [-0.1, 0, 0.1] + currentX;
    [maxfit, indexMax] = max(fit(solutionRange));
    currentX = solutionRange(indexMax);
    
    xValues(i) = currentX;
    yValues(i) = maxfit;
end

solution=xValues(numIterations);

end