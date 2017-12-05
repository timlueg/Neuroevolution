
[sumEliteFitness,sumEliteFitnessTest]=heartRatePrediction(200);
figure(1);
cla;
hold on;
plot(sumEliteFitness);
plot(sumEliteFitnessTest);
xlabel('Iteration');
ylabel('summed squared Error');
legend('TrainingError','TestError');
hold off;