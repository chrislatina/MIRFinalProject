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

%% N-FOLD
nFold = 6;
fold = 1:13;
filesInFolder = 60;
nSize = size(features,1);
nSize = nSize / nFold;

% DISTRIBUTED: Interleave vectors
F1 = features(1:filesInFolder,:); 
F2 = features(filesInFolder+1:2*filesInFolder,:);
F3 = features(2*filesInFolder+1:3*filesInFolder,:);
F4 = features(3*filesInFolder+1:4*filesInFolder,:);
F5 = features(4*filesInFolder+1:5*filesInFolder,:);
F6 = features(5*filesInFolder+1:6*filesInFolder,:);
F7 = features(6*filesInFolder+1:7*filesInFolder,:);
dist_features = reshape([F1';F2';F3';F4';F5';F6';F7'],13,[])';

G1 = genres(1:filesInFolder,:);
G2 = genres(filesInFolder+1:2*filesInFolder,:);
G3 = genres(2*filesInFolder+1:3*filesInFolder,:);
G4 = genres(3*filesInFolder+1:4*filesInFolder,:);
G5 = genres(4*filesInFolder+1:5*filesInFolder,:);
G6 = genres(5*filesInFolder+1:6*filesInFolder,:);
G7 = genres(6*filesInFolder+1:7*filesInFolder,:);
dist_labels = reshape([G1';G2';G3';G4';G5';G6';G7'],1,[])';

% Do Separation
for i = 1:nFold
    % DISTRIBUTED: Interleave vectors  
    s = (i-1)*nSize+1;
    e = i*nSize;
    test_feat = dist_features(s:e,:);
    test_labels(:,i) = dist_labels(s:e);
    train_feat = dist_features;
    genres = dist_labels;
    train_feat(s:e,:) = [];
    genres(s:e,:) = [];
    
    % Normalize using z-score
    test_feat = (test_feat - repmat(mean(train_feat),size(test_feat,1),1)) ./ repmat(std(train_feat),size(test_feat,1),1);
    train_feat = (train_feat - repmat(mean(train_feat),size(train_feat,1),1)) ./ repmat(std(train_feat),size(train_feat,1),1);

    
    %Run the SVM 
%      estimatedClasses(:,i) = svm_classify(train_feat, genres, test_feat);
%     % Run K-NN to calculate distance
    estimatedClasses(:,i) = myKnn_genre(genres, train_feat(:,fold), test_feat(:,fold), 7);
%     rate((i-1)*nSize+1:i*nSize,i) = strcmp(estimatedClasses(:,i), test_labels(:,i));
    rate((i-1)*nSize+1:i*nSize,1) = strcmp(estimatedClasses(:,i), test_labels(:,i));
end


% Generate the Confusion Matrix
[C,order] = confusionmat(test_labels(:),estimatedClasses(:));
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



