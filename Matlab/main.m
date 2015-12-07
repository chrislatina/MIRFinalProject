clear;

% Separate data into training and test sets based on nFold

clear;


%% Include vl_feat for the svm. If you don't have this installed, download at www.vlfeat.org
run('/Users/chrislatina/Documents/GeorgiaTech/F15/Comp Vision/Assignment 4/vlfeat-0.9.20/toolbox/vl_setup')
% run('/Users/musictechnology/Dropbox/Fall_2015/6476CS_CV/Projects/proj3/vlfeat-0.9.20/toolbox/vl_setup')

%%
% Extract features for each file
windowSize = 4096;
hopSize = 1024;

%%
% Folder path
folderPath = '/Users/chrislatina/Documents/GeorgiaTech/F15/MIR/FinalProject/Dataset';
% folderPath = '/Users/musictechnology/Desktop/Dataset_5';

%%
% Read in Data
dataPath = '/Users/chrislatina/Documents/Sites/MIRFinalProject/GTZAN60.txt';
% dataPath = '/Users/musictechnology/Desktop/MIRFinalProject/GTZAN60.txt';
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

% Values 1:13 represent the mean of MFCCs. 14:26 are Std Dev of MFCCs.
% 27:28 are mean and std devation of spectral flux
% 29:30 are mean and std devation of spectral centroid
%% Run NFold
[ diff_genres, diff_years] = myNFold(years, genres, features, 6, [1:13], 3);

%% Output the mean accuracy / error for genre and year
a_genre_rate = mean(diff_genres(:));
a_year_rate = mean(diff_years(:));


