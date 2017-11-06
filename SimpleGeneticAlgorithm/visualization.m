[timeline,fitnessTimeline,populationSize,numIterations]=eggGa();
AllElite=zeros(100,numIterations);
AllMedian=zeros(100,numIterations);
AllWorst=zeros(100,numIterations);

for i=1:100
[timeline,fitnessTimeline,populationSize,numIterations]=eggGa();
AllElite(i,:)=min(fitnessTimeline,[],2)';
AllMedian(i,:)=median(fitnessTimeline,2)';
AllWorst(i,:)=max(fitnessTimeline,[],2)';

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
