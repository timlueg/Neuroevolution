load iceland.dat
[x,y]=size(iceland);
surf(iceland);
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
validationSet=listOfIndex(NumberTraining+1:NumberTraining+NumberValidation,:);
testSet=listOfIndex(NumberTraining+NumberValidation+1:dataSize,:);
