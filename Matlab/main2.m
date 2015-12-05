clear;

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

[ rate, labels] = myNFold(years, genres, features, 6, [4:8 27], 3);

% Generate the Confusion Matrix
% [C,order] = confusionmat(test_genres(:),estimated_genres(:));
% num_songs_per_row = length(test_genres);
% figure(3);
% imagesc(C);
% title('Confusion Matrix');
% colormap(flipud(gray));  % Grayscale
% textStrings = num2str(C(:)./num_songs_per_row*100,'%0.2f');  % Generate strings for labels
% textStrings = strtrim(cellstr(textStrings)); 
% [x,y] = meshgrid(1:7);
% hStrings = text(x(:),y(:),textStrings(:),... 
%                 'HorizontalAlignment','center');
% midValue = mean(get(gca,'CLim')); 
% textColors = repmat(C(:) > midValue,1,3);
% set(hStrings,{'Color'},num2cell(textColors,2));
% 
% set(gca,'XTick',1:7,...                    
%         'XTickLabel',{order{1}, order{2}, order{3}, order{4}, order{5}, order{6}, order{7}},...
%         'YTick',1:7,...
%         'YTickLabel',{order{1}, order{2}, order{3}, order{4}, order{5}, order{6}, order{7}},...
%         'TickLength',[0 0]);
% 
% genre_rate = mean(rate);
% year_rate = mean(mean(diff_years,1));
% % end
