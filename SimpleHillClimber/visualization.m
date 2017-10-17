solutions=zeros(1,100);
plotX=zeros(100,100);
plotY=zeros(100,100);
fit = @(x) (x>1).*(2.*x-2) + (x<=0.5).*8.*x + ((x>0.5).*(x<=1)).*(-8.*x + 8);
parfor i=1:100
    [solutions(i),plotX(i,:),plotY(i,:)]=fitClimber();
end
figure(1);
h1=histogram(solutions,40);
xlabel('X Werte');
ylabel('absolute Häufigkeit');
figure(2);
boxplot(solutions);
ax=gca;
ax.XTickLabel = {'100 HillClimb Ergebnisse'};
ylabel('X Werte');