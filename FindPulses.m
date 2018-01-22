%% DATA GATHERING AND PULSE DETECTION PART --------------------------------
% -------------------------------------------------------------------------
% ToDo: 
% - Filter Signal
% - Improve Pulse detection (Template approach)
% - Improve Pulse duration detection

% Copyright Nils Brehm 2018

%% Open data
clear
clc
close all

path_linux = '/media/brehm/Data/Panama/DataForPaper/';
path_windows = 'D:\Masterarbeit\PanamaProject\DataForPaper\Melese_incertus\';

[file,path] = uigetfile([path_windows, '*.wav'],'select a wav file');
open(fullfile(path,file))

%% Use this to change the path:
path = '/media/brehm/Data/Panama/DataForPaper/Castur/PK1285/Pk12850006/';

%% Template
pulse_length = 0.6;
tau = 0.1;
frequency = 50;
mph = .2;
mpd = 300;
[pulse_locations, pulse_times, r, lags, template] = ...
    TemplatePeaks(data ,samplingrate/1000, pulse_length, ...
    frequency, tau, mph, mpd);
findpeaks(r, 'MinPeakHeight', mph, 'MinPeakDistance', mpd)

%%
mpp = 0;
mpw = 0;
th = 0.04;
findpeaks(r, 'MinPeakHeight', mph, 'MinPeakDistance', mpd,...
    'MinPeakWidth', mpw, 'MinPeakProminence', mpp, 'Annotate', 'extent', ...
    'Threshold', th)

%% Plot pulses found by template method
plot(data)
hold on
plot(pulse_locations, data(pulse_locations), 'ro')
hold on
template_time = 1:length(template);
shift = 1000;
plot(template_time + (pulse_locations(ceil(end/2))+shift), template, 'r')

%% Derivative Filter:
d1 = data; % save raw data
d1 = diff(d1);

%% ========================================================================
plot(data)

%% Sampling Rate Estimation
recduration = 100; % in ms
samplingrate_estimate = length(data)/(recduration/1000); % in Hz
samplingrate = 480 * 1000;
disp(['SAMPLING RATE: ', num2str(samplingrate/1000), ' kHz'])
noise = 0;

% Noise Filter: --------------------------------------------------------
if noise == 0
    plot(data)
    disp('Please selecet noise')
end

%% Noise filtering:
noisefactor = 10;
d1 = data; % save raw data
maxnoise = max(noise(:,2));
minnoise = min(noise(:,2));
cutoff1 = noisefactor*maxnoise;
cutoff2 = noisefactor*minnoise;
nn = max(noise); % in absolute amplitude
d1(d1<cutoff1 & d1>cutoff2) = 0;

%% Find Pulses
% Do you want to use noise filtered data?
filternoise = 0;

thresholdA = 1*std(data);
thresholdP = 1*std(data);
pulselength = 240; % in samples
manualcorrection = 0;
if filternoise == 1
    [Peak, samples] = findpulsesalgo(d1, thresholdA, thresholdP, pulselength, filternoise);
else
    [Peak, samples] = findpulsesalgo(data, thresholdA, thresholdP, pulselength, filternoise);
    
end

%% Plot pulses found
% a2.DataIndex-a1.DataIndex
clc
if filternoise == 1
    plot(d1, 'm', 'linewidth', 1.5)
else
    plot(data,'k', 'linewidth', 1.5)
end
hold on
for j = 1:length(samples.active)
    plot(samples.active(j), data(samples.active(j)), 'ro', 'MarkerSize', 8)
    hold on
end
for j = 1:length(samples.passive)
    plot(samples.passive(j), data(samples.passive(j)), 'bo', 'MarkerSize', 8)
    hold on
end

plot([1, length(data)], [thresholdA, thresholdA], 'g')
hold on
plot([1, length(data)], [-thresholdP, -thresholdP], 'g')

if filternoise == 1
    hold on
    plot([1, length(data)], [cutoff1, cutoff1], 'y')
    hold on
    plot(data, 'k', 'LineWidth', 0.8)
end
hold off

disp(['Active  Pulses Found: ', num2str(length(samples.active))])
disp(['Passive Pulses Found: ', num2str(length(samples.passive))])
disp(['Total Pulses Found: ', num2str(length(Peak))])

%% Detect Single Pulse Length
singlepulselength = zeros(1, length(Peak));
j = 1;
limit_spl = quantile(data, .95);

for i = Peak
    k = 0;
    %     while max(data(i+k:i+k+100)) > maxnoise
    while max(data(i+k:i+k+100)) >= limit_spl
        k = k+1;
        % Make sure that the pulse does not exceeds the next one
        if j < length(Peak) && (i+k) >= Peak(j+1)
            break;
        end
    end
    singlepulselength(j) = k;
    j = j+1;
end

% disp(['Min. pulse length: ', num2str(min(singlepulselength)), ' Samples'])


% Detect Call Statistics
IPIs = (diff(Peak)/samplingrate)*1000;
A_IPIs = (diff(samples.active)/samplingrate)*1000;
P_IPIs = (diff(samples.passive)/samplingrate)*1000;
ITI2 = (samples.passive(1)-samples.active(end))/samplingrate*1000; % only if A and P are completley separated
ITI = max(IPIs);  % Inter Train Interval: Interval between Active and Passive Train
pulse_train_duration = (max([samples.passive, samples.active]) - min([samples.passive, samples.active]))/samplingrate*1000;
A_dur = (max(samples.active) - min(samples.active)) / samplingrate * 1000;
P_dur = (max(samples.passive) - min(samples.passive)) / samplingrate * 1000;
spl = singlepulselength / samplingrate * 1000;
AP_length = mean(spl(1:length(samples.active)));
AP_length_std = std(spl(1:length(samples.active)));
PP_length = mean(spl(length(samples.active)+1:end));
PP_length_std = std(spl(length(samples.active)+1:end));

%Put all call statistics in one table
VarNames = {'A_No', 'A_MeanIPI', 'A_StdIPI', 'A_SemIPI', 'P_No',...
    'P_MeanIPI', 'P_StdIPI', 'P_SemIPI', 'ITI', 'ITI2', 'CallDur', ...
    'A_dur', 'P_dur', 'AP_length', 'AP_length_std', 'PP_length', 'PP_length_std'};
call_stats = table(length(samples.active), mean(A_IPIs), std(A_IPIs), std(A_IPIs)/sqrt(length(samples.active)), ...
    length(samples.passive), mean(P_IPIs), std(P_IPIs), std(P_IPIs)/sqrt(length(samples.passive)), ...
    ITI, ITI2, pulse_train_duration, A_dur, P_dur, ...
    AP_length, AP_length_std, PP_length, PP_length_std ,'VariableNames', VarNames);

%% save samples and call statistics
mkdir([path, file(1:end-4)]);
filename = [path, file(1:end-4), '\', file(1:end-4)];
save([filename, '_samples.mat'],'samples')
writetable(call_stats, [path, file(1:end-4), '\call_stats.xls'])
disp('Call Statistics saved!')





%% ========================================================================
%  ========================================================================
%% Add pulse manually
% Active
addactivepulse = addactivepulse.DataIndex;
id1 = max(find(samples.active < addactivepulse));
if isempty(id1) % This means new pulse is the new first pulse
    newsamples = addactivepulse;
    newsamples(end+1:length(samples.active)+1) = samples.active;
else
    newsamples = samples.active(1:id1);
    newsamples(end+1) = addactivepulse;
    newsamples(end+1:end+length(samples.active(id1+1:end))) = samples.active(id1+1:end);
end

samples.active = newsamples;

%% Passive
addpassivepulse = addpassivepulse.DataIndex;
id1 = max(find(samples.passive < addpassivepulse));

if isempty(id1) % This means new pulse is the new first pulse
    newsamples = addpassivepulse;
    newsamples(end+1:length(samples.passive)+1) = samples.passive;
else
    newsamples = samples.passive(1:id1);
    newsamples(end+1) = addpassivepulse;
    newsamples(end+1:end+length(samples.passive(id1+1:end))) = samples.passive(id1+1:end);
end
samples.passive = newsamples;

%% Remove pulses
% active
nr_a = 1;
samples.active(nr_a) = [];
Peak = [samples.active, samples.passive]; % Rebuild Peak

%% passive
nr_p = 1;
samples.passive(nr_p) = [];
Peak = [samples.active, samples.passive]; % Rebuild Peak

%%
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
%% Plot marked pulses with their respective pulse length
plot(data)
hold on
for p = 1:length(Peak)
plot(Peak(p):Peak(p)+singlepulselength(p), data(Peak(p):Peak(p)+singlepulselength(p)), 'r')
hold on
end

%% Manual Correction
if manualcorrection == 1
    replacement_index = 13;
    samples.passive(replacement_index) = cursor_info.DataIndex;
    deletion_index = 14;
    samples.active(deletion_index) = [];
    
    disp('After Manual Correction')
    disp(['Active  Pulses Found: ', num2str(length(samples.active))])
    disp(['Passive Pulses Found: ', num2str(length(samples.passive))])
    disp(['Total Pulses Found: ', num2str(length(Peak))])
    disp(['Total Pulses Found: ', num2str(length(Peak))])
end

%% ------------------------------------------------------------------------

%% If the recording contains more than one call use this:
% -------------------------------------------------------------------------
plot(data)

%% Decompose the recording into single calls
variablesInCurrentWorkspace = who;
no_callstarts = sum(strncmp('cstart',variablesInCurrentWorkspace, 6));
no_callends = sum(strncmp('cend',variablesInCurrentWorkspace, 4));
callstarts = [];
callends = [];
for i = 1:no_callstarts
    aa = "callstarts = [callstarts, cstart" +  num2str(i) + ".DataIndex]";
    eval(aa);
    bb = "callends = [callends, cend" +  num2str(i) + ".DataIndex]";
    eval(bb);
end

% countA = zeros(1,length(callstarts));
% countP = zeros(1,length(callstarts));
% 
% for i = 1:length(callstarts)
%     countA(i) = sum(samples.active >= callstarts(i) & samples.active <= callends(i));
%     countP(i) = sum(samples.passive >= callstarts(i) & samples.passive <= callends(i));
% end
% 
% pulsenumberA = [1, countA(1)];
% pulsenumberP = [1, countP(1)];
% for i = 2:length(countA)
%     pulsenumberA = [pulsenumberA; pulsenumberA(i-1,2)+1, countA(i)+sum(countA(1:i-1))];
%     pulsenumberP = [pulsenumberP; pulsenumberP(i-1,2)+1, countP(i)+sum(countP(1:i-1))];
% end

%% Save Single Calls as wave files
audio_path = [path, file(1:end-4)];
mkdir(audio_path);
for i = 1:length(callstarts)
    callaudio = data(callstarts(i):callends(i));
    audiowrite([audio_path, '\call_nr_', num2str(i),'.wav'],callaudio,samplingrate)
end

%% ========================================================================
% ++++ JUNKYARD +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% clear FoundPulses
% clear FoundActivePulses
% clear FoundPassivePulses
% step = 100;
% step_factor = 30;
% threshold = 0.2;
% peakthreshold = 0.3;
% count = 2;
% FoundPulses(count) = 0;
%
% for i = 1+2*step:length(data)-step_factor*step
%     if (max(data(i-2*step:i-step)) < threshold ...
%             || min(data(i-2*step:i-step)) > -threshold) ...
%             && (max(data(i:i+step_factor*step)) > threshold || min(data(i:i+step_factor*step)) < threshold ) ...
%             && (data(i) > peakthreshold || data(i) < -peakthreshold) ...
%             && (data(i) > data(i+1) || data(i) < data(i+1)) ...
%             && (data(i) > data(i-1) || data(i) < data(i-1)) ...
%             && i-FoundPulses(count-1)>step
%         if data(i) > peakthreshold
%             FoundActivePulses(count) = i;
%         elseif data(i) < -peakthreshold
%             FoundPassivePulses(count) = i;
%         end
%         FoundPulses(count) = i;
%         count = count + 1;
%     end
% end
% disp(["Found Active Pulses:", num2str(length(FoundActivePulses))])
% disp(["Found Passive Pulses:", num2str(length(FoundPassivePulses))])
%
% %%
% plot(data)
% hold on
% plot(FoundActivePulses, ones(1, length(FoundActivePulses))*max(data), 'ro', 'MarkerSize', 8)
% hold on
% plot(FoundPassivePulses, ones(1, length(FoundPassivePulses))*max(data), 'bx', 'MarkerSize', 8)