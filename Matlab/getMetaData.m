% =========================================================================
% This function extract features from the audio file, then generate the
% feature matrix including MFCC, Zero Crossing Rate, Max Envelop, Spectral
% Crest, Spectral Centroid, and Spectral Flux
% =========================================================================
% @param: dataPath is the directory of the audio meta data
% @param: filepath is the directory of audio files
% @param: windowSize
% @param: hopSize
% =========================================================================
% @retval features is a matrix with the size of total number of audio samples by number of features
% @retval genres is a vector with the size of total number of audio samples
% by 1.
% @retval feature vector in the size of number of audio samples by 1
% =========================================================================

function [ features, genres, years] = getMetaData(dataPath, filePath, windowSize, hopSize)

data = readtable(dataPath,'Delimiter','tab','ReadVariableNames',false);
num_tracks = size(data,1);
%Construct feature matrix and genre vector
features = zeros(num_tracks, 26);

% Open each file
for i = 1:num_tracks;
    genres{i} = data{i,5}{1};
    fileName = data{i,6}{1};
    years{i} = data{i,4};
    file = strcat(filePath, '/',fileName);
    [y,Fs] = audioread(file);
    
    %Convert to mono
    y = mean(y,2);
    
    %Block signal
    [blocked_x, numBlocks] = myBlockedInput(y, windowSize, hopSize);

    % Windowed FFT of each block
    window = hamming(windowSize, 'periodic');
    window = repmat(window, 1, numBlocks);
    freq_blocked_x = fft(window .* blocked_x);
    mag_freq_blocked_x = abs(freq_blocked_x);
        
    % Extract features per block
    mfcc = zeros(numBlocks, 13);
    for j = 1: numBlocks
        mfcc(j,:) = myMFCC(mag_freq_blocked_x(:,j), Fs)';
    end

    features(i,1:13) = mean(mfcc,1);
    features(i, 14:26) = std(mfcc,1);
end

genres = genres';
years = years';
end

