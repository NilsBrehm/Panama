%% Callseries To Single Calls
% This script converts call series to single calls
% Single calls must be cut out manually
% 
% Copyright Nils Brehm 2018

%% Open data
clear
clc
close all

base_path = '../../Recordings/Carales_astur/PK1289/';

[file,path] = uigetfile([base_path, '/*.wav'],'select a wav file');
open(fullfile(path,file))

samplingrate = 480 * 1000;

%% Plot callseries
% Please select start and end points of all single calls
% Name start points:    cs01 ... csxx
% Name end points:      ce01 ... cexx
plot(data)

%% Decompose the recording into single calls
variablesInCurrentWorkspace = who;
no_callstarts = sum(strncmp('cs',variablesInCurrentWorkspace, 2));
no_callends = sum(strncmp('ce',variablesInCurrentWorkspace, 2));
callstarts = [];
callends = [];
for i = 1:no_callstarts
    aa = "callstarts = [callstarts, cs" +  num2str(i) + ".DataIndex]";
    eval(aa);
    bb = "callends = [callends, ce" +  num2str(i) + ".DataIndex]";
    eval(bb);
end
clc

%% Save Single Calls as wave files
pathname = [path, file(1:end-4)];
mkdir(pathname);
for i = 1:length(callstarts)
    callaudio = data(callstarts(i):callends(i));
    audiowrite([pathname, '/call_nr_', num2str(i),'.wav'],callaudio,samplingrate)
end
disp('single call audio saved')