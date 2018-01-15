%% High Pass Filter Signal
clear
clc
[file,path] = uigetfile('/home/brehm/Desktop/songs/bats/*.wav','select a wav file');
open(fullfile(path,file))
%%
fc = 5000; % Cut off frequency
fs = 480*1000; % Sampling rate

[b,a] = butter(8,fc/(fs/2),'high'); % Butterworth filter of order 6
x = filter(b,a,data); % Will be the filtered signal


[pxx,f,pxxc] = periodogram(data,rectwin(length(data)),length(data),480000); 
[pxxY,fY,pxxcY] = periodogram(x,rectwin(length(x)),length(x),480000);

subplot(2,1,1)
plot(f,pxx, 'k')
hold on
plot(fY,pxxY, 'r')
hold off
xlim([0 100000])
subplot(2,1,2)
plot(data, 'k')
hold on
plot(x, 'r')

% filename = [path, file(1:end-4),'_filtered.wav'];
% audiowrite(filename,x,fs)
% disp('Filtered File was saved')

% audiowrite(file,x,fs)

%% Bat Calls
