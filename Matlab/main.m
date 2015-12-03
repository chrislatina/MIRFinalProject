clear;


%% Include vl_feat for the svm
run('/Users/chrislatina/Documents/GeorgiaTech/F15/Comp Vision/Assignment 4/vlfeat-0.9.20/toolbox/vl_setup')
% run('/Users/musictechnology/Dropbox/Fall_2015/6476CS_CV/Projects/proj3/vlfeat-0.9.20/toolbox/vl_setup')

%%
% Extract features for each file
windowSize = 4096;
hopSize = 1024;

%%
% Folder path
% folderPath = '/Users/chrislatina/Documents/GeorgiaTech/F15/MIR/FinalProject/Dataset';
folderPath = '/Users/musictechnology/Desktop/Dataset';

%%
% Read in Data
% dataPath = '/Users/chrislatina/Documents/Sites/MIRFinalProject/GTZAN60.txt';
dataPath = '/Users/musictechnology/Desktop/MIRFinalProject/GTZAN60.txt';
%%
% Extract Features -- if already loaded, just load from the file
if ~exist('features_final.mat', 'file')
    [features, genres, years] = getMetaData(dataPath, folderPath, windowSize, hopSize);
    save('features_final.mat', 'features');
    save('genres_final.mat', 'genres');
    save('years_final.mat', 'years');
else
    load('features_final.mat');
    load('genres_final.mat');
    load('years_final.mat');
end

unique_genres = unique(genres);
num_feat_per_genre = 60;

years = cell2mat(years);

% Generate a random seed
rand_seed = randperm(num_feat_per_genre);

% Randomize features for each genre
for i=1:length(unique_genres)
    temp_feat = features((i-1)*60+1:i*60);
    temp_genre= genres((i-1)*60+1:i*60);
    temp_year= years((i-1)*60+1:i*60);
    
    features((i-1)*60+1:i*60) = temp_feat(rand_seed);
    genres((i-1)*60+1:i*60) = temp_genre(rand_seed);
    years((i-1)*60+1:i*60) = temp_year(rand_seed);
end

% Construct test vs training data
train_feats = features(1:50,:);
train_genres = genres(1:50);
train_years = years(1:50);

test_feats = features(51:60,:);
test_genres = genres(51:60);
test_years = years(51:60);

for i=2:length(unique_genres)
    train_feats  = vertcat(train_feats,features((i-1)*60+1:(i-1)*60+50,:));
    train_genres = vertcat(train_genres,genres((i-1)*60+1:(i-1)*60+50,:));
    train_years  = vertcat(train_years,years((i-1)*60+1:(i-1)*60+50,:));
    
    test_feats   = vertcat(test_feats,features((i-1)*60+51:(i-1)*60+60,:));
    test_genres  = vertcat(test_genres,genres((i-1)*60+51:(i-1)*60+60,:));
    test_years   = vertcat(test_years,years((i-1)*60+51:(i-1)*60+60,:));
end

scaled_years = scaleYear(train_years);
%%
% Using SVM to predict the year as a regression
predicted_label = svm_regression(train_feats, scaled_years, test_feats);

%%
% Using SVM to predict the genre
predicted_categories = svm_classify(train_feats, train_genres, test_feats);

%% Use KNN to predict genre for comparison
% predicted_categories = myKnn_genre(train_genres, train_feats, test_feats, 7); 

% Show genre rate
g_diff = strcmp(test_genres, predicted_categories);
mean(g_diff);

% For each track, run K-NN for the specific genre selected.
for i=1:length(predicted_categories)
    
   %Get all tracks in training data of current genre
   predicted_genre = predicted_categories{i};
   indexC = strfind(train_genres, predicted_genre);
   indices = find(not(cellfun('isempty', indexC)));
   
   % Set K
   K = 3;
   estimatedClasses(i) = myKnn(years(indices), train_feats(indices,:), test_feats(i,:), K); 
end

diff = abs(estimatedClasses' - test_years);
mean(diff)