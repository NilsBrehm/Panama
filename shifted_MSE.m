function [minMSE, shift] = shifted_MSE(active, passive, windowstart, windowend)
% shifted_MSE  Aligns Pulses using Mean Squared Error (MSE).
%   [minMSE, shift] = shifted_MSE(active, passive, windowstart, windowend)
%   parameters:
%       active: active pulses (Matrix: rows = data, cols = pulse #)
%       passive: passive pulses (Matrix: rows = data, cols = pulse #)
%       windowstart: Starting point for analysis
%       windowend: End point for analysis
% returns: min. MSE and corresponding shift value
% 
% Copyright Nils Brehm 2017

noPulsesA = size(active, 2);
noPulsesP = size(passive, 2);
minMSE = zeros(noPulsesA, noPulsesP);
shift = zeros(noPulsesA, noPulsesP);

for i = 1:noPulsesA
    for k = 1:noPulsesP
        pulse_fixed = active(windowstart:windowend, i);
        pulse_compared = passive(windowstart:windowend, k);
        MSE = zeros(length(pulse_fixed),1);
        for j = 1:length(pulse_fixed)
            pulse_shifted  = circshift(pulse_compared,j);
            d = sqrt(mean((pulse_fixed-pulse_shifted).^2)); % Mean Squared Error
            MSE(j,1) = d;
        end
        [minMSE(i, k), shift(i, k)] = min(MSE);
    end
end
end
