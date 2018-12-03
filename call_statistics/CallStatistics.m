%% Call Statistics
% The idea is to automaticaly extract as much descriptive statistics about
% the pulse trains (calls) as possible.
% 
% - Pulse Duration (active and passive)
% - Inter Pulse Interval (IPI) (active and passive)
% - Inter Train Interval (ITI) (pause between active and passive train)
% - Pulse Train Duration (active and passive)
% - Call Duration
% - Frequency Components 
% 
% call_stats:
% 01: single pulse length
% 02: active single pulse length
% 03: passive single pulse length
% 04: Inter Pulse Intervals
% 05: Active Inter Pulse Intervals
% 06: Passive Inter Pulse Intervals
% 07: Inter Train Intervals (method 1)
% 08: Inter Train Intervals (method 2)
% 09: Call Duration
% 10: Active Train Duration
% 11: Passive Train Duration
% 12: Active Pulse Number
% 13: Passive Pulse Number
% 
% Copyright Nils Brehm 2018

%% Get number of calls in directory
clear
clc
animal = '/media/brehm/Data/Panama/DataForPaper/Castur/PK1285/';
rec_nr = 7;
disp(['number of recordings: ', num2str(rec_nr)])
d = dir(animal);
dirFlags = [d.isdir];
folders = d(dirFlags);
recordings = {folders.name};
recordings = recordings(3:(2+rec_nr));

%% Collect data from saved data
tic
call_stats = {};
q = 1;

for k = 1:length(recordings)
    pathname = [animal, recordings{k}, '/'];
    d = dir(pathname);
    dirFlags = [d.isdir];
    folders = d(dirFlags);
    number_of_calls = length(folders) - 2;
    
    % Loop through all calls
    for i = 1:number_of_calls
        filename = [pathname, 'call_nr_', num2str(i), '/call_nr_', num2str(i), '.mat'];
        load(filename,'data', 'samples', 'samplingrate', 'singlepulselength');
        
        % Compute Call Statistics
%         f = figure();
        call_stats(q, :) = compute_call_statistics(data,...
            samples, samplingrate, singlepulselength, true, false);
        q = q+1;
%         waitfor(f); % Wait until figure is closed
        
    end
    disp([num2str(k/length(recordings)*100), ' % done'])
end
toc

%
IPI_A = []; IPI_P = []; pl_A = []; pl_P = []; call_duration = [];
AT_duration = []; PT_duration = []; A_number = []; P_number = [];

for i = 1:size(call_stats, 1)
    IPI_A = [IPI_A, call_stats{i, 5}];
    IPI_P = [IPI_P, call_stats{i, 6}];
    pl_A = [pl_A, call_stats{i, 2}];
    pl_P = [pl_P, call_stats{i, 3}];
    call_duration = [call_duration, call_stats{i, 9}];
    AT_duration = [AT_duration, call_stats{i, 10}];
    PT_duration = [PT_duration, call_stats{i, 11}];
    A_number = [A_number, call_stats{i, 12}];
    P_number = [P_number, call_stats{i, 13}];
end

% Save Call Stats to HDD
save([animal, 'call_statistics.mat'])
disp('data saved')

%% Histogram IPI
figure()
plot_hist(pl_A, pl_P, 0.05, 'Pulse Duration [ms]', 'Probability', {'Active Pulses', 'Passive Pulses'})
% hold on
% plot([median(pl_A), median(pl_A)], [0, .5], 'b', 'LineWidth', 2)
% hold on
% plot([median(pl_P), median(pl_P)], [0, .5], 'r', 'LineWidth', 2)

%% BoxPlot IPI
% Rank Sum Test:
[p,~,~] = ranksum(IPI_A, IPI_P);
IPI = [IPI_A, IPI_P];
group = [zeros(1,length(IPI_A)), ones(1,length(IPI_P))];
figure()
boxplot(IPI, group, 'Labels', ...
    {['Active Pulses (n = ', num2str(length(IPI_A)), ')'],...
    ['Passive Pulses (n = ', num2str(length(IPI_P)), ')']},...
    'DataLim', [-10, 10], 'ExtremeMode', 'compress', 'colors', 'k')
ylabel('Inter Pulse Interval [ms]')
text(1.1, 8, ['Wilcoxon rank sum test: p = ', num2str(p)])
text(1.1, 7.5, ['Difference = ', num2str(round(abs(median(IPI_A)-median(IPI_P)), 3)), ' ms'])

%% BoxPlot Pulse Length
% Rank Sum Test:
[p,~,~] = ranksum(pl_A, pl_P);
% boxplot
PL = [pl_A, pl_P];
group = [zeros(1,length(pl_A)), ones(1,length(pl_P))];
figure()
boxplot(PL, group, 'Labels', ...
    {['Active Pulses (n = ', num2str(length(pl_A)), ')'],...
    ['Passive Pulses (n = ', num2str(length(pl_P)), ')']},...
     'colors', 'k')
ylabel('Pulse Duration [ms]')
text(1.1, 1.4, ['Wilcoxon rank sum test: p = ', num2str(p,4)])
text(1.1, 1.2, ['Difference = ', num2str(round(abs(median(pl_A)-median(pl_P)), 3)), ' ms'])

%% BoxPlot AT and PT duration
% Rank Sum Test:
[p,~,~] = ranksum(AT_duration, PT_duration);
% boxplot
dur = [AT_duration, PT_duration];
group = [zeros(1,length(AT_duration)), ones(1,length(PT_duration))];
figure()
boxplot(dur, group, 'Labels', ...
    {['Active Trains (n = ', num2str(length(AT_duration)), ')'],...
    ['Passive Trains (n = ', num2str(length(PT_duration)), ')']},...
     'colors', 'k')
ylabel('Train Duration [ms]')
text(1, 25, ['Wilcoxon rank sum test: p = ', num2str(round(p,3))])
text(1, 24, ['Difference = ', num2str(round(abs(median(AT_duration)-median(PT_duration)), 2)), ' ms'])