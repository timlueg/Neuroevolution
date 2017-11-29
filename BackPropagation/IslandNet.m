function [trainingError,validationError,testError]=IslandNet(learningRate)
load iceland.dat
[x,y]=size(iceland);
%surf(iceland);
dataSize=x*y;
listOfIndex=zeros(dataSize,3);

%learningRate = 0.06;
numIterations = 300;

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
W =randn(2,50);
W2 =randn(50,1);

trainingError=zeros(numIterations,1);
validationError=zeros(numIterations,1);
testError = zeros(numIterations,1);

for j=1:numIterations
    
    for i=1:numTraining
        input = trainingSetXY(i,:);
        [netLayer2, outLayer1, netLayer1] = netForward(input, W, W2);
        
        error = loss(trainingSetZ(i), netLayer2);
        trainingError(j) = trainingError(j) + error;
        
        delta2 = errorDerivative(trainingSetZ(i), netLayer2) .* sigmoidBackward(netLayer2);
        dW2 = outLayer1' * delta2;
        
        delta = delta2 * W2' ;
        dW1 = input' * delta;
        
        %adjust weights
        W = W - (dW1 .* learningRate);
        W2 = W2 - (dW2 .* learningRate);
    end
    
    %disp(trainingError(j));
    shuffleSelector = randperm(numTraining);
    trainingSetXY = trainingSetXY(shuffleSelector,:);
    trainingSetZ = trainingSetZ(shuffleSelector,:);
    
    %evaluate validatoin and test set error
    for l=1:numValidation
        input = validationSetXY(l,:);
        [netLayer2, outLayer1, netLayer1] = netForward(input, W, W2);
        validationError(j) = validationError(j) + loss(validationSetZ(l), netLayer2);
        
        input = testSetXY(l,:);
       [netLayer2, outLayer1, netLayer1] = netForward(input, W, W2);
        testError(j) = testError(j) + loss(testSetZ(l), netLayer2);
    end
    
    if mod(j,10) == 0
        disp(trainingError(j))
    end
    
end

end

function [netLayer2, outLayer1, netLayer1] = netForward(input, W, W2)
        netLayer1 = feedForward(input,W);
        outLayer1 = sigmoidForward(netLayer1);
        netLayer2 = feedForward(outLayer1, W2);
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
function [netOut] =feedForward(input,W)
%Zeilen
X = input;
netOut = X * W ;
end
