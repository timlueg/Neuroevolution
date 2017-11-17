load iceland.dat
[x,y]=size(iceland);
%surf(iceland);
dataSize=x*y;
listOfIndex=zeros(dataSize,3);
k=1;

training=0.70;
validation=0.15;
test=0.15;

NumberTraining=floor(training*dataSize);
NumberValidation=floor(validation*dataSize);
NumberTest=floor(test*dataSize);

for i=1:x
    for j=1:y
        listOfIndex(k,1)=i;
        listOfIndex(k,2)=j;
        listOfIndex(k,3)=iceland(i,j);
        k=k+1;
    end
end

listOfIndex=listOfIndex(randperm(x*y),:);
trainingSet=listOfIndex(1:NumberTraining,:);
trainingSetXY=trainingSet(:,1:2);
trainingSetZ=trainingSet(:,3);

validationSet=listOfIndex(NumberTraining+1:NumberTraining+NumberValidation,:);
validationSetXY=validationSet(:,1:2);
validationSetZ=validationSet(:,3);

testSet=listOfIndex(NumberTraining+NumberValidation+1:dataSize,:);
testSetXY=testSet(:,1:2);
testSetZ=testSet(:,3);

meanXY=mean(trainingSetXY,1);
trainingSetXY= trainingSetXY ./ meanXY;
meanXY=mean(validationSetXY,1);
validationSetXY= validationSetXY ./ meanXY;
meanXY=mean(testSetXY,1);
testSetXY= testSetXY ./ meanXY;


%Gewichtsmatrix
W = ones(2,1);
sumSquaredError=0;
for i=1:NumberTraining
    netLayer1=feedForward(trainingSetXY(i,1:2),W);
    outLayer1=sigmoidForward(netLayer1);
    Error=loss(trainingSetZ(i),outLayer1);
    sumSquaredError = sumSquaredError + Error;
    
end

function [activation]=sigmoidForward(X)
activation= 1 ./(1+exp(-X));
end

function [sigmoidDerivative]=sigmoidBackward(X)
gx=sigmoidForward(X);
sigmoidDerivative= gx *(1-gx);
end
function [error]= loss(target,out)
error=0.5* (target-out)^2;
end
function [errorDerivative]=lossDerivative(target,out)
errorDerivative = -(target-out);
end
function[]=feedBackward(error,W)

end
function [netOut] =feedForward(input,W)
%Zeilen
X = input;
netOut = X * W ;
end
