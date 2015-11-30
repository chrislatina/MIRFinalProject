% Include vl_feat for the svm
run('/Users/chrislatina/Documents/GeorgiaTech/F15/Comp Vision/Assignment 4/vlfeat-0.9.20/toolbox/vl_setup')

% Extract features for each file
windowSize = 4096;
hopSize = 1024;

% Folder path
folderPath = '/Users/chrislatina/Documents/GeorgiaTech/F15/MIR/FinalProject/ShortDataset';

% Read in Data
dataPath = '/Users/chrislatina/Documents/GeorgiaTech/F15/MIR/FinalProject/App/MIRFINAL/test.csv';

[features, genres] = getMetaData2(dataPath, folderPath, windowSize, hopSize);

train__feats = features(1:45,:);
train_labels = genres(1:45);
test_feats = features(46:55,:);
test_labels = genres(46:55);

% Calculate 
predicted_categories = svm_classify(train_feats, train_labels, test_feats);

% For each track, run K-NN for the specific genre selected.
for i=1:length(predicted_categories)
    
   %Get all tracks in training data of current genre
   predicted_genre = predicted_categories{i};
   indexC = strfind(train_labels, predicted_genre);
   indices = find(not(cellfun('isempty', indexC)));
   
   % Set K
   K = 5;
   estimatedClasses(:,i) = myKnn(genres, train_image_feats(indices,:), test_feats(i,:), K); 
end