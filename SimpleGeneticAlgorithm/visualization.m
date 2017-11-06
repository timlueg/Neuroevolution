%[history,fitnessHistory,populationSize,numIterations]=eggGa();
[history,fitnessHistory,populationSize,numIterations]=eggGA_vectorized();

numExperiments = 100;
AllElite=zeros(numExperiments,numIterations);
AllMedian=zeros(numExperiments,numIterations);
AllWorst=zeros(numExperiments,numIterations);

for i=1:numExperiments
[history,fitnessHistory,populationSize,numIterations]=eggGa();
AllElite(i,:)=min(fitnessHistory,[],2)';
AllMedian(i,:)=median(fitnessHistory,2)';
AllWorst(i,:)=max(fitnessHistory,[],2)';

end
eliteDevelopment=mean(AllElite,1);
medianDevelopment=mean(AllMedian,1);
worstDevelopment=mean(AllWorst,1);
cla;
figure(1);
hold on;

plot(eliteDevelopment);
plot(medianDevelopment);
plot(worstDevelopment);
legend('Elite','Median','Worst');
hold off;

figure(2);
boxplot(AllElite(:,numIterations));
