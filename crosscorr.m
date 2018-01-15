function [crosscorrelation, MaxCorr, BestLag] = crosscorr(active, passive, windowstart, windowend, mode)
% crosscorr  Computes cross correlation between pulses
%   [crosscorrelation, MaxCorr, BestLag] = crosscorr(active, passive, windowstart, windowend, mode)
%   parameters:
%       active: active pulses (Matrix: rows = data, cols = pulse #)
%       passive: passive pulses (Matrix: rows = data, cols = pulse #)
%       windowstart: Starting point for analysis
%       windowend: End point for analysis
%       mode: scale option for xcorr. ('none', 'biased', 'unbiased', 'coeff')
% returns: cross correlation, max. Correlation value and corresponding lag
% 
% Copyright Nils Brehm 2017 

% Compute cross correlation
noPulsesA = size(active, 2);
noPulsesP = size(passive, 2);

crosscorrelation = cell(noPulsesA,noPulsesP);
for i = 1:noPulsesA
    for k = 1:noPulsesP
        [crosscorrelation{i,k}(:,1), crosscorrelation{i,k}(:,2)] = ...
            xcorr(active(windowstart:windowend,i), passive(windowstart:windowend,k), mode);
    end
end

% Get max. Correlation (depending on lag)
MaxCorr = zeros(noPulsesA, noPulsesP);
BestLag = zeros(noPulsesA, noPulsesP);
for j = 1:noPulsesA
    for u = 1:noPulsesP
        [value, col] = max(abs(crosscorrelation{j, u}(:, 1)));
        MaxCorr(j, u) = value;
        BestLag(j, u) = crosscorrelation{j, u}(col, 2);
    end
end
end