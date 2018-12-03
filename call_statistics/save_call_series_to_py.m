%% Get names of recordings
clear
clc
close all
% base_path = '/media/brehm/Data/Panama/DataForPaper/Lophocampa/';
base_path = '/media/nils/Data/Moth/CallStats/mothcallseries/';
rec_path = base_path;
listing = dir(rec_path);
recs = {};
count = 1;
for i = 3:length(listing)
    if strcmp(listing(i).name(end-2:end), 'wav')
        recs{count} = listing(i).name;
        count = count + 1;
    end
end
%% Get Pulse Times and Call Duration
samples = cell(length(recs), 1);
call_dur = cell(length(recs), 1);
p_rate = zeros(length(recs), 1);
dc = zeros(length(recs), 1);
nr = zeros(length(recs), 1);
for k = 1:length(recs)
    [~, fs] = audioread([base_path, recs{k}]);
    dummy = load([base_path, recs{k}(1:end-4), '/samples.mat']);
    dummy2 = [dummy.samples.active, dummy.samples.passive];
    samples{k} = dummy2 / fs;
    call_dur{k} = max(dummy2) / fs;
    
    p_rate(k) = length(dummy2) / (max(dummy2) / fs);
    dc(k) = length(samples{k}) * 0.0005 / max(samples{k}); 
    nr(k) = length(dummy2);
end

%% Pulse rate


%% Save for Python
save('/media/nils/Data/Moth/CallStats/CallSeries_Stats/samples.mat', 'samples');
save('/media/nils/Data/Moth/CallStats/CallSeries_Stats/call_dur.mat', 'call_dur');
disp('Saved data for PYTHON')
