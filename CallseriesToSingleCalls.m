%% Open data
clear
clc
close all
[file,path] = uigetfile('/media/brehm/Data/Panama/data/new_carales_recs/Castur/PK1285/*.wav','select a wav file');
open(fullfile(path,file))

samplingrate = 480 * 1000;

%% Plot callseries
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

%% Save Single Calls as wave files
pathname = [path, file(1:end-4)];
mkdir(pathname);
for i = 1:length(callstarts)
    callaudio = data(callstarts(i):callends(i));
    audiowrite([pathname, '/call_nr_', num2str(i),'.wav'],callaudio,samplingrate)
end
disp('single call audio saved')