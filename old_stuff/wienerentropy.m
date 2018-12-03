for i = 1:size(pulses.active, 2)
        spfA(i) = log(spectral_flatness(pulses.active(:, i)));
end

for i = 1:size(pulses.passive, 2)
        spfP(i) = log(spectral_flatness(pulses.passive(:, i)));
end