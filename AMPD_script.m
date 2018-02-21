
signal = downsample(data,2);
plot_it = false;

%%
signal = diff(envelope(signal));

%% Automatic Multiscale-based Peak Detection
peaks_pos = ampd(signal);
peaks_neg = ampd(-signal);

%%
plot(signal, 'k')
hold on
plot(peaks_pos, signal(peaks_pos), 'ro')

%% Thresholding Peaks
th = 0.1;
pulse_duration = 100;

indx_pos = find(signal(peaks_pos) > th);
PEAKS_pos = peaks_pos(indx_pos);

indx_neg = find(signal(peaks_neg) < -th);
PEAKS_neg = peaks_neg(indx_neg);

samples.pos = [];
samples.neg = [];

if plot_it
    figure()
    plot(signal, 'k')
    hold on
    plot(PEAKS_neg, signal(PEAKS_neg), 'ro')
end
% Positive
samples.pos(1) = PEAKS_pos(1);
count = 2;
for i = 1:1:length(PEAKS_pos)-1
    if abs(PEAKS_pos(i)-PEAKS_pos(i+1)) > pulse_duration    
        samples.pos(count) = PEAKS_pos(i+1);
        count = 1 + count;
    end
end

if plot_it
    figure()
    plot(signal, 'k')
    hold on
    plot(samples.pos, signal(samples.pos), 'ro')
end

% Negative
samples.neg(1) = PEAKS_neg(1);
count = 2;
for i = 1:1:length(PEAKS_neg)-1
    if abs(PEAKS_neg(i)-PEAKS_neg(i+1)) > pulse_duration    
        samples.neg(count) = PEAKS_neg(i+1);
        count = 1 + count;
    end
end

% plot(signal, 'k')
% hold on
% plot(samples.neg, signal(samples.neg), 'ro')

% Active or Passive?
id1 = samples.pos < samples.neg;
samples.active = samples.pos(id1);
id2 = samples.pos > samples.neg;
samples.passive = samples.neg(id2);

figure()
plot(signal, 'k')
hold on
plot(samples.active, signal(samples.active), 'ro')
hold on
plot(samples.passive, signal(samples.passive), 'bo')
disp(['active: ', num2str(length(samples.active))])
disp(['passive: ', num2str(length(samples.passive))])

%%-------------------------------------------------------------------------
%% Thresholding Algo Function:
% add zeros
data = [zeros(200, 1); data];

%%
[signals,avgFilter,stdFilter] = ThresholdingAlgo(data, 50, 10, 0.5, 'mean');
peaks = diff(signals);

%%
plot(data); hold on; plot(avgFilter, 'r'); hold on; plot(avgFilter+stdFilter, 'r--'); hold on; plot(avgFilter-stdFilter, 'r--')
%hold on
%plot(signals, 'b')
hold on
plot(peaks,'g')


%%
clear samples
pulse_duration = 50;
p = find(peaks == 1);
p = [0 ;p];
%samples.pos(1) = p(1);
count = 1;
count_a = 1;
count_p = 1;
for i = 1:1:length(p)-1
    if abs(p(i)-p(i+1)) > pulse_duration    
        samples.pos(count) = p(i+1);
        count = 1 + count;
        % Active or Passive?
        if data(p(i+1)) >= 0
           samples.active(count_a) = p(i+1);
           count_a = count_a + 1;
        else
            samples.passive(count_p) = p(i+1);
            count_p = count_p + 1;
        end
    end
end

plot(data, 'k')
hold on
plot(samples.active, data(samples.active), 'ro')
hold on
plot(samples.passive, data(samples.passive), 'bo')
disp(['active: ', num2str(length(samples.active))])
disp(['passive: ', num2str(length(samples.passive))])

%% Find Peaks Envelope Algo:
[peaks, peaks_diff, samples] = find_peaks_env(data, 100, 'rms', 20, true);
