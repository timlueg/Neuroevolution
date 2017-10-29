load fisheriris;

learningRate = 0.1;

activation = @(x)(x>0);

Y = strcmp(species, 'versicolor');
[n_examples, n_outputs] = size(Y);

X = [ones(n_examples,1),meas(:,1),meas(:,2)];
[n_examples, n_inputs] = size(X);

W = -1 + 2 * rand(3,1);
netInput = X * W;
netOut = activation(netInput);

for i=1:100
    %for j=1:n_examples
        %W  = W + (learningRate * (Y(j) - netOut(j)) * X(j,:)');
    %end
    %disp(W)
    W = W + X' * learningRate * (Y - netOut)
end


prediction = activation(X * W)


