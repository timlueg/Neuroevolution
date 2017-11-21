function [trainingError,validationError,testError]=IslandNet(learningRate)
load iceland.dat
[x,y]=size(iceland);
%surf(iceland);
dataSize=x*y;
listOfIndex=zeros(dataSize,3);

%learningRate = 0.06;
numIterations = 1000;

training=0.70;
validation=0.15;
test=0.15;

numTraining=floor(training*dataSize);
numValidation=floor(validation*dataSize);
numTest=floor(test*dataSize);

k=1;
for i=1:x
    for j=1:y
        listOfIndex(k,1)=i;
        listOfIndex(k,2)=j;
        listOfIndex(k,3)=iceland(i,j);
        k=k+1;
    end
end

listOfIndex=listOfIndex(randperm(x*y),:);
trainingSet=listOfIndex(1:numTraining,:);
trainingSetXY=trainingSet(:,1:2);
trainingSetZ=trainingSet(:,3);

validationSet=listOfIndex(numTraining+1:numTraining+numValidation,:);
validationSetXY=validationSet(:,1:2);
validationSetZ=validationSet(:,3);

testSet=listOfIndex(numTraining+numValidation+1:dataSize,:);
testSetXY=testSet(:,1:2);
testSetZ=testSet(:,3);

trainingSetXY= trainingSetXY ./ mean(trainingSetXY,1);
validationSetXY= validationSetXY ./ mean(validationSetXY,1);
testSetXY= testSetXY ./ mean(testSetXY,1);


trainingSetZ = trainingSetZ ./ abs(max(trainingSetZ,[], 1));
validationSetZ = validationSetZ ./ abs(max(validationSetZ,[], 1));
testSetZ = testSetZ ./ abs(max(testSetZ,[], 1));



%Gewichtsmatrix
W =randn(2,20);
W2 =randn(20,1);

trainingError=zeros(numIterations,1);
validationError=zeros(numIterations,1);
testError = zeros(numIterations,1);

for j=1:numIterations
    
    
    
    for i=1:numTraining
        input = trainingSetXY(i,:);
        netLayer1 = feedForward(input,W);
        outLayer1 = sigmoidForward(netLayer1);
        netLayer2 = feedForward(outLayer1, W2);
        outLayer2 = sigmoidForward(netLayer2);
        
        error = loss(trainingSetZ(i), outLayer2);
        trainingError(j) = trainingError(j) + error;
        
        delta2 = errorDerivative(trainingSetZ(i), outLayer2) .* sigmoidBackward(outLayer2);
        dw2 = outLayer2' * delta2;
        
        delta = dw2 * W2' .* sigmoidBackward(outLayer2);
        dw1 = input' * delta;
        
        %adjust weights
        W = W - (dw1 .* learningRate);
        W2 = W2 - (dw2 .* learningRate);
    end
    
    %disp(trainingError(j));
    shuffleSelector = randperm(numTraining);
    trainingSetXY = trainingSetXY(shuffleSelector,:);
    trainingSetZ = trainingSetZ(shuffleSelector,:);
    
    %evaluate validatoin and test set error
    for l=1:numValidation
        %todo replace dublicate feedforewared with function call
        input = validationSetXY(l,:);
        netLayer1 = feedForward(input,W);
        outLayer1 = sigmoidForward(netLayer1);
        netLayer2 = feedForward(outLayer1, W2);
        outLayer2 = sigmoidForward(netLayer2);
        
        validationError(j) = validationError(j) + loss(validationSetZ(l), outLayer2);
        
        %todo replace dublicate feedforewared with function call
        nput = testSetXY(l,:);
        netLayer1 = feedForward(input,W);
        outLayer1 = sigmoidForward(netLayer1);
        netLayer2 = feedForward(outLayer1, W2);
        outLayer2 = sigmoidForward(netLayer2);
        
        testError(j) = testError(j) + loss(testSetZ(l), outLayer2);
    end
    
    
end

end
function [activation]=sigmoidForward(X)
activation= 1 ./(1+exp(-X));
end

function [sigmoidDerivative]=sigmoidBackward(X)
gx=sigmoidForward(X);
sigmoidDerivative= gx .* (1-gx);
end
function [error]= loss(target,out)
error=0.5* (target-out)^2;
end
function [dError]=errorDerivative(target,out)
dError = -(target-out);
end
function[]=feedBackward(error,W)

end
function [netOut] =feedForward(input,W)
%Zeilen
X = input;
netOut = X * W ;
end
