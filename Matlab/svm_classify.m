% =========================================================================
% Support Vector Machine is typical classification model
% =========================================================================
% @param train_feats: feature vector of training samples
% @param train_labels: vector of labels of training samples
% @param test_feats: feature vector of testing samples
% =========================================================================

function predicted_categories = svm_classify(train_feats, train_labels, test_feats)
categories = unique(train_labels); 
num_categories = length(categories);

num_train = size(train_feats, 1);
num_test = size(test_feats, 1);
dim = size(test_feats, 2);
Ws = zeros(num_categories, dim);
Bs = zeros(num_categories, 1);
Lambda = 0.001;

for i = 1: num_categories
    labels = ones(num_train,1).*-1;
    labels(strcmp(categories{i}, train_labels)) = 1;
    [W, B] = vl_svmtrain(train_feats', labels, Lambda, 'MaxNumIterations', 1e5);
    Ws(i,:) = W';
    Bs(i) = B;
  
end

confidences = Ws * test_feats' + repmat(Bs,1,num_test);
[~, indices] = max(confidences);
predicted_categories = categories(indices);
end
