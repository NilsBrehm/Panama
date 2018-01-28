% Call Statistics of several animals
% This brings the data from CallStatistics.m of many animals together.
% 
% - Pulse Duration (active and passive)
% - Inter Pulse Interval (IPI) (active and passive)
% - Inter Train Interval (ITI) (pause between active and passive train)
% - Pulse Train Duration (active and passive)
% - Call Duration
% - Frequency Components 
% 
% Copyright Nils Brehm 2018

%% Load Data
clear
clc
pathname = 'D:\Masterarbeit\PanamaProject\DataForPaper\Castur\';
animals = {'PK1285', 'PK1287', 'PK1289'};

for i = 1:length(animals)
    animal_path = [pathname, animals{i}, '\'];
    data{i} = load([animal_path, 'call_statistics.mat']);
end

%% Collect Data
IPI_A = []; IPI_P = []; pl_A = []; pl_P = []; AT_dur = []; PT_dur = [];
ITI = []; call_dur = [];
group_IPI_A = []; group_IPI_P = []; group_pl_A = []; group_pl_P = [];
group_AT_dur = []; group_PT_dur = [];
n_IPI_A = zeros(1, length(animals));
n_IPI_P = zeros(1, length(animals));
n_pl_A = zeros(1, length(animals));
n_pl_P = zeros(1, length(animals));
n_AT_dur = zeros(1, length(animals));
n_PT_dur = zeros(1, length(animals));
legend_label_IPI_A = cell(1, length(animals));
legend_label_IPI_P = cell(1, length(animals));
legend_label_pl_A = cell(1, length(animals));
legend_label_pl_P = cell(1, length(animals));
legend_label_AT_dur = cell(1, length(animals));
legend_label_PT_dur = cell(1, length(animals));

for k = 1:length(animals)
    
    d = data{1,k};
    n_IPI_A(k) = (length(d.IPI_A));
    n_IPI_P(k) = (length(d.IPI_P));
    n_pl_A(k) = (length(d.pl_A));
    n_pl_P(k) = (length(d.pl_P));
    n_AT_dur(k) = (length(d.AT_duration));
    n_PT_dur(k) = (length(d.PT_duration));
    
    IPI_A_median(k) = median(d.IPI_A);
    IPI_P_median(k) = median(d.IPI_P);
    pl_A_median(k) = median(d.pl_A);
    pl_P_median(k) = median(d.pl_P);
    AT_dur_median(k) = median(d.AT_duration);
    PT_dur_median(k) = median(d.PT_duration);
    ITI_median(k) = median(cell2mat(d.call_stats(:,7)));
    call_dur_median(k) = median(d.call_duration);
    
    IPI_A = [IPI_A, d.IPI_A];
    IPI_P = [IPI_P, d.IPI_P];
    pl_A = [pl_A, d.pl_A];
    pl_P = [pl_P, d.pl_P];
    AT_dur = [AT_dur, d.AT_duration];
    PT_dur = [PT_dur, d.PT_duration];
    ITI = [ITI,  cell2mat(d.call_stats(:,7))'];
    call_dur = [call_dur, d.call_duration];
    
    group_IPI_A = [group_IPI_A, ones(1, n_IPI_A(k))*k];
    group_IPI_P = [group_IPI_P, ones(1, n_IPI_P(k))*k];
    group_pl_A = [group_pl_A, ones(1, n_pl_A(k))*k];
    group_pl_P = [group_pl_P, ones(1, n_pl_P(k))*k];
    group_AT_dur = [group_AT_dur, ones(1, n_AT_dur(k))*k];
    group_PT_dur = [group_PT_dur, ones(1, n_PT_dur(k))*k];
    
    legend_label_IPI_A{k} = [animals{k}, ' (n=', num2str(n_IPI_A(k)), ')'];
    legend_label_IPI_P{k} = [animals{k}, ' (n=', num2str(n_IPI_P(k)), ')'];
    legend_label_pl_A{k} = [animals{k}, ' (n=', num2str(n_pl_A(k)), ')'];
    legend_label_pl_P{k} = [animals{k}, ' (n=', num2str(n_pl_P(k)), ')'];
    legend_label_AT_dur{k} = [animals{k}, ' (n=', num2str(n_AT_dur(k)), ')'];
    legend_label_PT_dur{k} = [animals{k}, ' (n=', num2str(n_PT_dur(k)), ')'];
    
    
end
n_ITI = n_AT_dur;
n_call_dur = n_ITI;
group_ITI = group_AT_dur;
group_call_dur = group_AT_dur;
legend_label_ITI = legend_label_AT_dur;
legend_label_call_dur = legend_label_AT_dur;

% -------------------------------------------------------------------------
%% PLOTTING SECTION
% -----------------
%% Box Plot Active IPI
pos_fig = [100 100 1000 600];
figure()
set(gcf, 'Color', 'white', 'position', pos_fig)
labely = 'Active Interpulse Interval [ms]';
plot_boxplot(IPI_A, group_IPI_A, legend_label_IPI_A, [-10, 6], labely)
ylim([0 inf])
title('Active Interpulse Intervals')
text(1.3, IPI_A_median(1), num2str(round(IPI_A_median(1),2)), 'FontSize', 14, 'Color', 'k')
text(2.3, IPI_A_median(2), num2str(round(IPI_A_median(2),2)), 'FontSize', 14, 'Color', 'k')
text(3.3, IPI_A_median(3), num2str(round(IPI_A_median(3),2)), 'FontSize', 14, 'Color', 'k')

export_fig([pathname, 'A_IPI.png'], '-r300', '-q101')
close

%% Box Plot Passive IPI
figure()
set(gcf, 'Color', 'white', 'position', pos_fig)
labely = 'Passive Interpulse Interval [ms]';
plot_boxplot(IPI_P, group_IPI_P, legend_label_IPI_P, [-10, 20], labely)
ylim([0 inf])
title('Passive Interpulse Intervals')
text(1.3, IPI_P_median(1), num2str(round(IPI_P_median(1),2)), 'FontSize', 14, 'Color', 'k')
text(2.3, IPI_P_median(2), num2str(round(IPI_P_median(2),2)), 'FontSize', 14, 'Color', 'k')
text(3.3, IPI_P_median(3), num2str(round(IPI_P_median(3),2)), 'FontSize', 14, 'Color', 'k')

export_fig([pathname, 'P_IPI.png'], '-r300', '-q101')
close

%% Box Plot Active Pulse Duration
figure()
set(gcf, 'Color', 'white', 'position', pos_fig)
labely = 'Active Pulse Duration [ms]';
plot_boxplot(pl_A, group_pl_A, legend_label_pl_A, [-10, 5], labely)
ylim([0 inf])
yticks(0:.5:5)
title('Acive Pulse Duration')
text(1.3, pl_A_median(1), num2str(round(pl_A_median(1),2)), 'FontSize', 14, 'Color', 'k')
text(2.3, pl_A_median(2), num2str(round(pl_A_median(2),2)), 'FontSize', 14, 'Color', 'k')
text(3.3, pl_A_median(3), num2str(round(pl_A_median(3),2)), 'FontSize', 14, 'Color', 'k')

export_fig([pathname, 'A_PDur.png'], '-r300', '-q101')
close

%% Box Plot Passive Pulse Duration
figure()
set(gcf, 'Color', 'white', 'position', pos_fig)
labely = 'Passive Pulse Duration [ms]';
plot_boxplot(pl_P, group_pl_P, legend_label_pl_P, [-10, 5], labely)
ylim([0 inf])
yticks(0:.5:5)
title('Passive Pulse Duration')
text(1.3, pl_P_median(1), num2str(round(pl_P_median(1),2)), 'FontSize', 14, 'Color', 'k')
text(2.3, pl_P_median(2), num2str(round(pl_P_median(2),2)), 'FontSize', 14, 'Color', 'k')
text(3.3, pl_P_median(3), num2str(round(pl_P_median(3),2)), 'FontSize', 14, 'Color', 'k')

export_fig([pathname, 'P_PDur.png'], '-r300', '-q101')
close

%% Box Plot Active Train Duration
figure()
set(gcf, 'Color', 'white', 'position', pos_fig)
labely = 'Active Train Duration [ms]';
plot_boxplot(AT_dur, group_AT_dur, legend_label_AT_dur, [-10, 80], labely)
ylim([0 inf])
yticks(0:20:100)
title('Active Train Duration')
text(1.3, AT_dur_median(1), num2str(round(AT_dur_median(1),2)), 'FontSize', 14, 'Color', 'k')
text(2.3, AT_dur_median(2), num2str(round(AT_dur_median(2),2)), 'FontSize', 14, 'Color', 'k')
text(3.3, AT_dur_median(3), num2str(round(AT_dur_median(3),2)), 'FontSize', 14, 'Color', 'k')

export_fig([pathname, 'A_TrainDur.png'], '-r300', '-q101')
close

%% Box Plot Passive Train Duration
figure()
set(gcf, 'Color', 'white', 'position', pos_fig)
labely = 'Passive Train Duration [ms]';
plot_boxplot(PT_dur, group_PT_dur, legend_label_PT_dur, [-10, 200], labely)
ylim([0 inf])
yticks(0:20:500)
title('Passive Train Duration')
text(1.3, PT_dur_median(1), num2str(round(PT_dur_median(1),2)), 'FontSize', 14, 'Color', 'k')
text(2.3, PT_dur_median(2), num2str(round(PT_dur_median(2),2)), 'FontSize', 14, 'Color', 'k')
text(3.3, PT_dur_median(3), num2str(round(PT_dur_median(3),2)), 'FontSize', 14, 'Color', 'k')

export_fig([pathname, 'P_TrainDur.png'], '-r300', '-q101')
close

%% Box Plot Inter Train Interval
figure()
set(gcf, 'Color', 'white', 'position', pos_fig)
labely = 'Intertrain Interval [ms]';
plot_boxplot(ITI, group_ITI, legend_label_ITI, [-10, 120], labely)
ylim([0 inf])
yticks(0:20:250)
title('Intertrain Interval')
text(1.3, ITI_median(1), num2str(round(ITI_median(1),2)), 'FontSize', 14, 'Color', 'k')
text(2.3, ITI_median(2), num2str(round(ITI_median(2),2)), 'FontSize', 14, 'Color', 'k')
text(3.3, ITI_median(3), num2str(round(ITI_median(3),2)), 'FontSize', 14, 'Color', 'k')

export_fig([pathname, 'ITI.png'], '-r300', '-q101')
close

%% Box Plot Call Duration
figure()
set(gcf, 'Color', 'white', 'position', pos_fig)
labely = 'Call Duration [ms]';
plot_boxplot(call_dur, group_call_dur, legend_label_call_dur, [-10, 400], labely)
ylim([0 inf])
yticks(0:50:500)
title('Call Duration')
text(1.3, call_dur_median(1), num2str(round(call_dur_median(1),2)), 'FontSize', 14, 'Color', 'k')
text(2.3, call_dur_median(2), num2str(round(call_dur_median(2),2)), 'FontSize', 14, 'Color', 'k')
text(3.3, call_dur_median(3), num2str(round(call_dur_median(3),2)), 'FontSize', 14, 'Color', 'k')

export_fig([pathname, 'call_dur.png'], '-r300', '-q101')
close

