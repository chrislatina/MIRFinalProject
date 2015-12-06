% =========================================================================
% @param trainLabel: label of training sample
% @param traingData: training audio sample
% @param testData: testing audio sample
% @param K       : Kth nearest neighbor of the cluster center
% =========================================================================
% @retval estimatedClass: estimated label of testing audio sample
% =========================================================================

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

f_dist = (1- (k_dist / (sum(k_dist)))) / (K-1);

estimatedClass = mean(f_dist' .* years) * K;

end