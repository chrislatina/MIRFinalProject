% =========================================================================
% Mel-Frequency Ceptral Coeeficients are perceptually motivated features.
% Typically, 13 coeeficients are used for speech representation.
% =========================================================================
% @param X: Magnitude spectrum of audio signal
% @param fs: sampling frequency
% =========================================================================
% @retval mfcc: the matrix of MFCC in the size of number of audio samples *
% 13
% =========================================================================

function [mfcc] = myMFCC(X, fs)

iNumCoeffs  = 13;
    
    % allocate memory
    mfcc  = zeros(iNumCoeffs, size(X,2));

    H  = ToolMfccFb(size(X,1), fs);
    T  = GenerateDctMatrix (size(H,1), iNumCoeffs);
 
    for n = 1:size(X,2)
        % compute the mel spectrum
        X_Mel = log10(H * X(:,n)+1e-20);

        % calculate the mfccs
        mfcc(:,n)  = T * X_Mel;
    end
end


%> see function mfcc.m from Slaneys Auditory Toolbox
function [T] = GenerateDctMatrix (iNumBands, iNumCepstralCoeffs)
    T = cos((0:(iNumCepstralCoeffs-1))' * (2*(0:(iNumBands-1))+1) * pi/2/iNumBands);
            
    T = T/sqrt(iNumBands/2);
    T(1,:) = T(1,:) * sqrt(2)/2;
end

function [H] = ToolMfccFb (iFftLength, f_s)

    % initialization
    f_start         = 133.3333;
    
    iNumLinFilters  = 13;
    iNumLogFilters  = 27;
    iNumFilters     = iNumLinFilters + iNumLogFilters;

    linearSpacing   = 66.66666666;
    logSpacing      = 1.0711703;

    % compute band frequencies
    f               = f_start + (0:iNumLinFilters-1)*linearSpacing;
    f(iNumLinFilters+1:iNumFilters+2) = ...
		      f(iNumLinFilters) * logSpacing.^(1:iNumLogFilters+2);

    % sanity check
    f               = f (f<f_s/2);
    iNumFilters     = length(f)-2;
    
    f_l             = f(1:iNumFilters);
    f_c             = f(2:iNumFilters+1);
    f_u             = f(3:iNumFilters+2);

    % allocate memory for filters and set max amplitude
    H               = zeros(iNumFilters,iFftLength);
    afFilterMax     = 2./(f_u-f_l);
    f_k             = (0:iFftLength-1)/iFftLength*f_s/2;

    % compute the transfer functions
    for c = 1:iNumFilters
        H(c,:)      = ...
            (f_k > f_l(c) & f_k <= f_c(c)).* ...
            afFilterMax(c).*(f_k-f_l(c))/(f_c(c)-f_l(c)) + ...
            (f_k > f_c(c) & f_k < f_u(c)).* ...
            afFilterMax(c).*(f_u(c)-f_k)/(f_u(c)-f_c(c));
    end
end