% function [ rate, labels] = myNFold( labels, features, nFold, fold, K)
% Separate data into training and test sets based on nFold

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
folderPath = '/Users/chrislatina/Documents/GeorgiaTech/F15/MIR/FinalProject/Dataset';
% folderPath = '/Users/musictechnology/Desktop/Dataset';

%%
% Read in Data
dataPath = '/Users/chrislatina/Documents/Sites/MIRFinalProject/GTZAN60.txt';
%dataPath = '/Users/musictechnology/Desktop/MIRFinalProject/GTZAN60.txt';
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

if ~exist('spectral_features.mat', 'file')
    [spectral_features, genres, years] = getSpectralFeatures(dataPath, folderPath, windowSize, hopSize);
    save('spectral_features.mat', 'spectral_features');
else
    load('spectral_features.mat', 'spectral_features');
end

% Construct High Dimensional Feature Matrix
features = [features, spectral_features];

unique_genres = unique(genres);
num_feat_per_genre = 60;

years = cell2mat(years);

%% N-FOLD
nFold = 6;
fold = 1:13;
filesInFolder = 60;
nSize = size(features,1);
nSize = nSize / nFold;

num_features = size(features,2);

% RANDOM
seed = randperm(size(features,1));
rand_genres = genres(seed);
rand_years = years(seed);
randData = features(seed,:);

% DISTRIBUTED: Interleave vectors
F1 = features(1:filesInFolder,:); 
F2 = features(filesInFolder+1:2*filesInFolder,:);
F3 = features(2*filesInFolder+1:3*filesInFolder,:);
F4 = features(3*filesInFolder+1:4*filesInFolder,:);
F5 = features(4*filesInFolder+1:5*filesInFolder,:);
F6 = features(5*filesInFolder+1:6*filesInFolder,:);
F7 = features(6*filesInFolder+1:7*filesInFolder,:);
dist_features = reshape([F1';F2';F3';F4';F5';F6';F7'],num_features,[])';

G1 = genres(1:filesInFolder,:);
G2 = genres(filesInFolder+1:2*filesInFolder,:);
G3 = genres(2*filesInFolder+1:3*filesInFolder,:);
G4 = genres(3*filesInFolder+1:4*filesInFolder,:);
G5 = genres(4*filesInFolder+1:5*filesInFolder,:);
G6 = genres(5*filesInFolder+1:6*filesInFolder,:);
G7 = genres(6*filesInFolder+1:7*filesInFolder,:);
dist_genres = reshape([G1';G2';G3';G4';G5';G6';G7'],1,[])';

Y1 = years(1:filesInFolder,:);
Y2 = years(filesInFolder+1:2*filesInFolder,:);
Y3 = years(2*filesInFolder+1:3*filesInFolder,:);
Y4 = years(3*filesInFolder+1:4*filesInFolder,:);
Y5 = years(4*filesInFolder+1:5*filesInFolder,:);
Y6 = years(5*filesInFolder+1:6*filesInFolder,:);
Y7 = years(6*filesInFolder+1:7*filesInFolder,:);
dist_years = reshape([Y1';Y2';Y3';Y4';Y5';Y6';Y7'],1,[])';

% Do Separation
for i = 1:nFold
    
    % RANDOM
    s = (i-1)*nSize+1;
    e = i*nSize;
    test_feat = randData(s:e,:);
    test_genres(:,i) = rand_genres(s:e);
    test_years(:,i) = rand_years(s:e);
    train_feat = randData;
    train_genres = rand_genres;
    train_years = rand_years;
    train_feat(s:e,:) = [];
    train_genres(s:e,:) = [];
    train_years(s:e,:) = [];
    
    % DISTRIBUTED: Interleave vectors  
%     s = (i-1)*nSize+1;
%     e = i*nSize;
%     test_feat = dist_features(s:e,:);
%     test_genres(:,i) = dist_genres(s:e);
%     test_years(:,i) = dist_genres(s:e);
%     train_feat = dist_features;
%     train_genres = dist_genres;
%     train_years = dist_years;
%     train_feat(s:e,:) = [];
%     train_genres(s:e,:) = [];
%     train_years(s:e,:) = [];
    
    % Normalize using z-score
    test_feat = (test_feat - repmat(mean(train_feat),size(test_feat,1),1)) ./ repmat(std(train_feat),size(test_feat,1),1);
    train_feat = (train_feat - repmat(mean(train_feat),size(train_feat,1),1)) ./ repmat(std(train_feat),size(train_feat,1),1);

    
    %% Run the SVM for Genre
    estimated_genres(:,i) = svm_classify(train_feat, train_genres, test_feat);
     
    %% Run SVM for Year
%     estimated_years(:,i) = svm_regression(train_feat, scaleYear(train_years), test_feat,scaleYear(test_years(:,i)));
%     estimated_years(:,i) = reScaleYear(estimated_years(:,i));

    %% Run K-NN to calculate Genre distance
    % estimatedClasses(:,i) = myKnn_genre(train_genres, train_feat(:,fold), test_feat(:,fold), 7);
    
    %% For each track, calculate year: run K-NN for the specific genre selected.
    for j=1:length(estimated_genres)

       %Get all tracks in training data of current genre
       predicted_genre = estimated_genres{i};
       indexC = strfind(train_genres, predicted_genre);
       indices = find(not(cellfun('isempty', indexC)));

       % Set K
       K = 3;
       estimated_years(:,j) = myKnn(years(indices), train_feat(indices,:), test_feat(j,:), K); 
    end
    
    %% Genre Rate
    rate((i-1)*nSize+1:i*nSize,1) = strcmp(estimated_genres(:,i), test_genres(:,i));
    
    %% Year Rate
    diff_years(:,i) = abs(estimated_years(:,i) - test_years(:,i));
end


% Generate the Confusion Matrix
[C,order] = confusionmat(test_genres(:),estimated_genres(:));
figure(3);
imagesc(C);
title('Confusion Matrix');
colormap(flipud(gray));  % Grayscale
textStrings = num2str(C(:),'%0.2f');  % Generate strings for labels
textStrings = strtrim(cellstr(textStrings)); 
[x,y] = meshgrid(1:7);
hStrings = text(x(:),y(:),textStrings(:),... 
                'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim')); 
textColors = repmat(C(:) > midValue,1,3);
set(hStrings,{'Color'},num2cell(textColors,2));

set(gca,'XTick',1:7,...                    
        'XTickLabel',{order{1}, order{2}, order{3}, order{4}, order{5}, order{6}, order{7}},...
        'YTick',1:7,...
        'YTickLabel',{order{1}, order{2}, order{3}, order{4}, order{5}, order{6}, order{7}},...
        'TickLength',[0 0]);

rate = mean(rate);

% end



