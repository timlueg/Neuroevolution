[trainingError,validationError,testError]=IslandNet(0.1);
learningRates=[0.01,0.05,0.1,0.15,0.2,0.5];

cla;
figure(1);
hold on;

plot(trainingError);
plot(validationError);
plot(testError);
legend('Training','Validation','Test');
xlabel('Iteration');
ylabel('summed squared Error');
hold off;

trainingErrors=zeros(size(learningRates(),2),size(trainingError(),1));
parfor i=1:size(learningRates(),2)
    [trainingError,validationError,testError]=IslandNet(learningRates(i));
    trainingErrors(i,:)=trainingError';
end
figure(2);
hold on;
for i=1:size(learningRates(),2)
   plot(trainingErrors(i,:)); 
end
legend('0.01','0.05','0.1','0.15','0.2','0.5');
xlabel('Iteration');
ylabel('summed squared Error');

hold off;