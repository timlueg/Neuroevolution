load iceland.dat
[x,y]=size(iceland);
%surf(iceland);
dataSize=x*y;
listOfIndex=zeros(dataSize,3);

learingRate = 0.2;
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

meanXY=mean(trainingSetXY,1);
trainingSetXY= trainingSetXY ./ meanXY;
meanXY=mean(validationSetXY,1);
validationSetXY= validationSetXY ./ meanXY;
trainingSetZ = trainingSetZ ./ abs(max(trainingSetZ,[], 1));

meanXY=mean(testSetXY,1);
testSetXY= testSetXY ./ meanXY;


%Gewichtsmatrix
W = rand(2,20);
W2 = rand(20,1);

for j=1:numIterations
   
    sumSquaredError=0;
    for i=1:numTraining
        input = trainingSetXY(i,1:2);
        netLayer1 = feedForward(input,W);
        outLayer1 = sigmoidForward(netLayer1);
        netLayer2 = feedForward(outLayer1, W2);
        outLayer2 = sigmoidForward(netLayer2);
        
        error = loss(trainingSetZ(i), outLayer2);
        sumSquaredError = sumSquaredError + error;
        
        %deltak = (trainingSetZ(i) - outLayer1) .* outLayer1 .* (1 - outLayer1);
        
        delta2 = errorDerivative(trainingSetZ(i), outLayer2) .* sigmoidBackward(outLayer2);
        dw2 = outLayer2' * delta2;
        
        delta = dw2 * W2' .* sigmoidBackward(outLayer2);
        dw1 = input' * delta;
        
        
        W = W - (dw1 .* learingRate);
        W2 = W2 - (dw2 .* learingRate);
    end
    
    disp(sumSquaredError);
    shuffleSelector = randperm(numTraining);
    trainingSetXY = trainingSetXY(shuffleSelector,:);
    trainingSetZ = trainingSetZ(shuffleSelector,:);
    
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
