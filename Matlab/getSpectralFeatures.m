% =========================================================================
% This function extract the spectral features from the audio sample, then
% organize them into feature matrix
% =========================================================================
% @param dataPath: the directory of meatadata
% @param filePath: the directory of audio samples
% @param windowSize
% @param hopSize
% =========================================================================
% @retval spectral_features: feature matrix in the size of N by 28
% including spectral centroid, spectral flux, and pitch chroma
% @retval genres: genre label of the song
% @retval years: year label of the song

function [spectral_features, genres, years] = getSpectralFeatures(dataPath, filePath, windowSize, hopSize)

data = readtable(dataPath,'Delimiter','tab','ReadVariableNames',false);
num_tracks = size(data,1);

%Construct feature matrix and genre vector
spectral_features = zeros(num_tracks, 28);

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
    sc = zeros(numBlocks, 1);
    pc = zeros(numBlocks, 12);
    for j = 1: numBlocks
        sc (j) = mySC(mag_freq_blocked_x(:, j), Fs);
        pc (j,:) = myPC(mag_freq_blocked_x(:, j), Fs)';
    end
    
    sf = mySF(mag_freq_blocked_x);

    spectral_features(i, 1) = mean(sf);
    spectral_features(i, 2) = std(sf);        
    spectral_features(i, 3) = mean(sc);
    spectral_features(i, 4) = std(sc);
    spectral_features(i, 5:16) = mean(pc,1);
    spectral_features(i, 17:end) = std(pc,1);
 end

genres = genres';
years = years';
end