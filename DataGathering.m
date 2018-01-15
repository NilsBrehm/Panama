%% DATA GATHERING PART ----------------------------------------------------
% -------------------------------------------------------------------------
%% Open data 
clear
clc
[file,path] = uigetfile('D:\Masterarbeit\2017-12-21\Panama\DataForPaper\*.wav','select a wav file');
open(fullfile(path,file))
%% View data
% Select single clicks manually with cursor and save it to workspace
figure; plot(data)

% spectrogram(data, 500, [], 256, 480000, 'yaxis')

% % With Time Axis:
% tt = 0:(1/480000):length(data)/480000;
% tt(end) = [];
% figure; plot(tt*1000,data)

%% Put click starting points into array
variablesInCurrentWorkspace = who;
no_pulses = sum(strncmp('pulse',variablesInCurrentWorkspace, 5));
samples.pulses = [];
for i = 1:no_pulses
    if i<= 9
        aa = "samples.pulses = [samples.pulses, pulse0" +  num2str(i) + "(1).Position(1)]";
    else
        aa = "samples.pulses = [samples.pulses, pulse" +  num2str(i) + "(1).Position(1)]";
    end
    eval(aa);
end

samples.active = samples.pulses(1:4);
samples.passive = samples.pulses(5:end);
% variablesInCurrentWorkspace = who;
% no_active = sum(strncmp('activepulse',variablesInCurrentWorkspace,11));
% no_passive = sum(strncmp('passivepulse',variablesInCurrentWorkspace,12));
% samples.active = [];
% samples.passive = [];
% for i = 1:no_active
%     aa = "samples.active = [samples.active, activepulse" +  num2str(i) + "(1).Position(1)]";
%     eval(aa);
% end
% for i = 1:no_passive
%     pp = "samples.passive = [samples.passive, passivepulse" +  num2str(i) + "(1).Position(1)]";
%     eval(pp);
% end

%% save samples
mkdir([path, file(1:end-4)]);
filename = [path, file(1:end-4), '/', file(1:end-4)];
save([filename, '_samples.mat'],'samples')