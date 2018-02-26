%% Open data
clear
clc
close all

%path_linux = '/media/brehm/Data/Panama/DataForPaper/Lophocampa/';
path_linux = '/media/brehm/Data/MasterMoth/stimuli/naturalmothcalls/';
%path_windows = 'D:\Masterarbeit\PanamaProject\DataForPaper\';

[file,path] = uigetfile([path_linux, '*.wav'],'select a wav file');
open(fullfile(path,file))

%% Open data
clear
clc
close all

path_linux = '/media/brehm/Data/MasterMoth/stimuli/naturalmothcalls/';
path_windows = 'D:\Masterarbeit\PanamaProject\DataForPaper\';

[file,path] = uigetfile([path_linux, '*.wav'],'select a wav file');
open(fullfile(path,file))

%% Filter Data
clc
fs = 480 * 1000;
x = bandpassfilter_data(data, 4000, 150*1000, 2, fs, true, true);
%x = data;
% Parameters
show_plot = true;

% plot(x)

%% Find peaks in recording
x = [zeros(200, 1); x];
mpd = 100;
th = 2*std(x);
[locs_ps, ~] = peakseek(x, mpd, th);
plot(x, 'k')
hold on
plot(locs_ps, x(locs_ps), 'mx', 'MarkerSize', 10)
disp(length(locs_ps))
disp(file)

%%
clc
th_factor = .5 ; % th = th_factor * mad(pulse)
limit = 30;
filter_pulse = false;
show = [false, true];
method = 'raw';
apriori = false; % assumption that first half is active and second is passive
samples = activeorpassive(x, th_factor, locs_ps, fs, limit, filter_pulse, method, apriori, show);
disp(['active ', num2str(length(samples.active))])
disp(['passive ', num2str(length(samples.passive))])
disp(file)

%% save samples
mkdir([path, file(1:end-4)]);
filename = [path, file(1:end-4), '/', file(1:end-4)];
save([filename, '_samples.mat'],'samples')
disp('Samples saved')
