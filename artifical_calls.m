%% ARTIFICIAL CALL
% This script computes artificial moth calls. The single pulses are based
% on a damped sinus model.

clear
clc

% Constants:
samplingrate = 480 * 1000; % sampling rate in Hz
pulse_length = 0.4;
tau = 0.1;
t = 0:1/samplingrate:pulse_length/1000; % pulse length = 0.4 ms
amp = 1;
dumping = tau/1000; % tau in seconds (0.1 ms)
xshift = 0; % no shift

%% Compute single pulses
clear pulses
frequency = {[34, 75],[33, 74],[33, 72],[32, 72],[30, 70], [32, 70], [35, 65], [32, 62], [38, 58], [40]};
w = {[.4, .6], [.4, .6], [.4, .6], [.4, .6], [.4, .6], [.4, .6], [.4, .6], [.3, .5], [.4, .5], [.6]};

for k = 1:length(frequency)
    pulse = 0;
    for i = 1:length(frequency{k})
        f = frequency{k}(i)*1000*2*pi;
        pulse = pulse + artifical_moth(t,w{k}(i)*amp,f, dumping, xshift);
    end
    jitter_limit = 0.1;
    jitterA = -jitter_limit + (jitter_limit+jitter_limit)*rand(1,length(t));
    pulses.active(:,k) = pulse; %+ jitterA;
    jitterP = -jitter_limit + (jitter_limit+jitter_limit)*rand(1,length(t));
    pulses.passive(:,11-k) = -pulse; %+ jitterP;
end

%% Put all pulses into one call
all_pulses = [pulses.active, pulses.passive];
PulseNO = size(all_pulses,2);
aa = (PulseNO/2);
interval = 500;
ITI = 2000;
pulse_length = length(pulses.active);
% call = zeros(1,length(pulses.active)*6);
% pos = [100, pulse_length+100, 2*pulse_length+100];
call = zeros(1,100);
for k = 1:PulseNO
    if k == aa
        call(end+1:end+length(all_pulses(:,k))) = all_pulses(:,k);
        call(end+1:end+ITI) = zeros(1,ITI);
    else
         call(end+1:end+length(all_pulses(:,k))) = all_pulses(:,k);
         call(end+1:end+interval) = zeros(1,interval);
    end
%     call(a+1:a+length(all_pulses(:,k))) = all_pulses(:,k); 
end
call(end+1:end+100) = zeros(1, 100);
figure()
plot(call)

%% Cross Correlate all single pulses
noPulsesA = PulseNO/2;
noPulsesP = PulseNO/2;
windowstart = 1;
windowend = length(pulses.active(:,1));
[ccAP, MaxCorr_AP, BestLag_AP] = crosscorr(pulses.active, pulses.passive, windowstart, windowend, 'coeff');
[ccAA, MaxCorr_AA, BestLag_AA] = crosscorr(pulses.active, pulses.active, windowstart, windowend, 'coeff');
[ccPP, MaxCorr_PP, BestLag_PP] = crosscorr(pulses.passive, pulses.passive, windowstart, windowend, 'coeff');

