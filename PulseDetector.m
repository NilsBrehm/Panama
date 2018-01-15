%% Detect Pulses
M = mean(data);
error = std(data);

count = 0;
for i = 1:length(data)
if max(abs(data(i:i+10))) < 0.02 && data(i+11) > 0.06
    count = count + 1;
    peaks(count) = i+1;
end
end

%%
plot(data)
hold on
plot(peaks, zeros(1,length(peaks)), 'o')
hold off