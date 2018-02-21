%% Testing wavelet transform, nonlinear energy operator and PeakSeek.
% 

%% Wavelet Transform
[cA,cD] = dwt(data,'db1');

%%
lvl = 1:20;
for i = 1:length(lvl)
[C,L] = wavedec(data ,lvl(i), 'db1');
% Plot
plot(data, 'k')
hold on
plot(C, 'r')
hold off
title(['lvl: ', num2str(lvl(i))])
pause(1)
end

%% NonLinear Energy Operator
% http://gaidi.ca/weblog/extracting-spikes-from-neural-electrophysiology-in-matlab
x = data;
neo = zeros(length(x),1);
for n = 2:1:length(x)-1
    neo(n) = x(n).^2 - x(n+1)*x(n-1);
end

%% Plot
plot(x*max(neo), 'k')
hold on
plot(neo, 'r')

%% PeakSeek
clc
x = bandpassfilter_data(data, 5000, 150*1000, 4, 480*1000, true, true);
[locs, pks] = peakseek(x, 100, .03);
plot(x);hold on; plot(locs, x(locs), 'ro')
disp(['pulses: ', num2str(length(locs))])