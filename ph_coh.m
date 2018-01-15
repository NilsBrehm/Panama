function phase_coh = ph_coh(active, passive, windowstart, windowend)

% Compute Phase Coherence
noPulses = size(active, 2);
phase_coh = zeros(noPulses,noPulses);
for ii = 1:noPulses
    for k = 1:noPulses
        phase_coh(ii, k) = ...
            abs(mean(exp(1i*(active(windowstart:windowend,ii) - passive(windowstart:windowend,k)))));
    end
end
end