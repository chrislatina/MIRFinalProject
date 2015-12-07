% =========================================================================
% To see the performance of classifier, using N-fold to have a cross
% validation
% =========================================================================
% @param years:
% @param genres:
% @param features:
% @param nFold: the number of 
% @param fold
% @param K: number of first kth neighbor
% =========================================================================
% @retval diff_genres: the absolute difference between the estimated genre 
% and groundtruth 
% @retval diff_years: the absolute difference between the estimated year
% and groundtruth
% =========================================================================

function [ diff_genres, diff_years] = myNFold( years, genres, features, nFold, fold, K)

features = features(:,fold);

unique_genres = unique(genres);
num_feat_per_genre = 60;

years = cell2mat(years);
histogram(years);

%% N-FOLD
filesInFolder = 60;
nSize = size(features,1);
nSize = nSize / nFold;

num_features = size(features,2);

%% RANDOM
seed = randperm(size(features,1));
rand_genres = genres(seed);
rand_years = years(seed);
randData = features(seed,:);

%% DISTRIBUTED: Interleave vectors
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

%% Perform NFold
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


    %% DISTRIBUTED: Interleave vectors, uncomment this for interleaved segmentation
%     s = (i-1)*nSize+1;
%     e = i*nSize;
%     test_feat = dist_features(s:e,:);
%     test_genres(:,i) = dist_genres(s:e);
%     test_years(:,i) = dist_years(s:e);
%     train_feat = dist_features;
%     train_genres = dist_genres;
%     train_years = dist_years;
%     train_feat(s:e,:) = [];
%     train_genres(s:e,:) = [];
%     train_years(s:e,:) = [];
    
    %% Normalize using z-score
    test_feat = (test_feat - repmat(mean(train_feat),size(test_feat,1),1)) ./ repmat(std(train_feat),size(test_feat,1),1);
    train_feat = (train_feat - repmat(mean(train_feat),size(train_feat,1),1)) ./ repmat(std(train_feat),size(train_feat,1),1);

    
    %% Run for SVM Genre classification
     estimated_genres(:,i) = svm_classify(train_feat, train_genres, test_feat);
     
    %% Run SVM for Year, uncomment this for SVM Regression approach
%     estimated_years(:,i) = svm_regression(train_feat, scaleYear(train_years), test_feat,scaleYear(test_years(:,i)));
%     estimated_years(:,i) = reScaleYear(estimated_years(:,i));

    %% Run K-NN to calculate Year and Genre distances
    [estimated_genres(:,i), estimated_years(:,i)] = myKnn_year(train_genres, train_feat, test_feat, 7, train_years);
    
    %% For each track, calculate year: run K-NN for the specific genre selected.
%     for j=1:length(estimated_genres)
% 
%        %Get all tracks in training data of current genre
%        predicted_genre = test_genres{i};
%        
%        % Or uncomment below to use ground thruth
%        % predicted_genre = test_genres{i};
% 
%        indexC = strfind(train_genres, predicted_genre);
%        indices = find(not(cellfun('isempty', indexC)));
%        
%        % Set K
%        K = 9;
%        estimated_years(:,j) = myKnn(train_years(indices), train_feat(indices,:), test_feat(j,:), K); 
%     end
    
    %% Genre Rate
    diff_genres((i-1)*nSize+1:i*nSize,1) = strcmp(estimated_genres(:,i), test_genres(:,i));
    
    %% Year Rate
    diff_years(:,i) = abs(estimated_years(:,i) - test_years(:,i));
    
end
% Generate the Confusion Matrix
[C,order] = confusionmat(test_genres(:),estimated_genres(:));
num_songs_per_row = length(test_genres);
figure(3);
imagesc(C);
title('Confusion Matrix');
colormap(flipud(gray));  % Grayscale
textStrings = num2str(C(:)./num_songs_per_row*100,'%0.2f');  % Generate strings for labels
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
% end

end
