function [estimatedClass] = myKnn(trainLabel, trainData, testData, K)
% k-Nearest Neighbor (Knn)

num_train = size(trainData,1);
num_test = size(testData,1);
distance = zeros(num_test, num_train);

for i=1:num_test
   for j=1:num_train
        distance(i,j) = sqrt(sum ((testData(i,:) - trainData(j,:)).^2));
    end
end

%Sort the distances
[B, I] = sort(distance,2,'ascend');

%Select the first K distances
years = trainLabel(I(:,1:K));
k_dist = B(:,1:K);

estimatedClass = mean([years(1) years(2)]);

end