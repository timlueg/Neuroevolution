
num_Iterations = 500;
repetitions = 10;
allElites = zeros(repetitions,num_Iterations);
allMedians = zeros(repetitions,num_Iterations);
allNodes = zeros(repetitions,num_Iterations);
allConnections = zeros(repetitions,num_Iterations);

parfor i=1:repetitions
[allElites(i,:), allMedians(i,:),allNodes(i,:),allConnections(i,:)]= neat_network(num_Iterations);
end

figure(1);
cla;
hold on;
plot(min(allElites,[],1));
plot(mean(allElites,1));
plot(mean(allMedians,1));
xlabel('Generationen');
ylabel('summed squared Error');
legend('Elite','durchschnittliche Elite','durchschnittlicher Median');
hold off;

figure(2)
cla;
hold on;
plot(mean(allConnections,1));
plot(mean(allNodes,1));
xlabel('Generationen');
ylabel('Anzahl');
legend('durchschnittliche Kanten der Elite','durchschnittliche Knoten der Elite');
hold off;
