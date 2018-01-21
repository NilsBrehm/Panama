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
% Copyright Nils Brehm 2018

%% Get number of calls in directory
clear
clc
recordings = {'Pk12850006', 'Pk12850008', 'Pk12850009', 'Pk12850011', 'Pk12850012', 'Pk12850013', 'Pk12850014'};
% recordings = {'Pk12870020'};

%% Collect data from saved data
IPI_A = [];
IPI_P = [];
call_duration = [];
pl_A = [];
pl_P = [];
for k = 1:length(recordings)
    pathname = ['D:\Masterarbeit\PanamaProject\DataForPaper\Castur\PK1285\', recordings{k}, '\'];
    d = dir(pathname);
    dirFlags = [d.isdir];
    folders = d(dirFlags);
    number_of_calls = length(folders) - 2;
    
    % Loop through all calls
    for i = 1:number_of_calls
        filename = [pathname, 'call_nr_', num2str(i), '\call_nr_', num2str(i), '.mat'];
        load(filename, 'A_IPIs', 'P_IPIs', 'samples', 'samplingrate', ...
            'singlepulselength');
        IPI_A = [IPI_A, A_IPIs];
        IPI_P = [IPI_P, P_IPIs];
        
        pulse_train_duration = (max([samples.passive, samples.active]) - min([samples.passive, samples.active]))/samplingrate*1000;
        call_duration = [call_duration, pulse_train_duration];
        
        spl = singlepulselength / samplingrate * 1000;
        spl_A = spl(1:length(samples.active));
        spl_P = spl(length(samples.active)+1:end);
        pl_A = [pl_A, spl_A];
        pl_P = [pl_P, spl_P];
        
        if sum(spl > 2)
            disp(['Look at: ',recordings{k} , ' - call nr  ', num2str(i)])
        end
    end
    
end

%% Histogram
figure()
histogram(IPI_A, 'Normalization', 'probability')
xlabel('Active IPI [ms]')
ylabel('Probability')

%% BoxPlot IPI
IPI = [IPI_A, IPI_P];
group = [zeros(1,length(IPI_A)), ones(1,length(IPI_P))];
figure()
boxplot(IPI, group, 'Labels', ...
    {['Active Pulses (n = ', num2str(length(IPI_A)), ')'],...
    ['Passive Pulses (n = ', num2str(length(IPI_P)), ')']},...
    'DataLim', [-10, 10], 'ExtremeMode', 'compress', 'colors', 'k')
ylabel('Inter Pulse Interval [ms]')

%% BoxPlot Pulse Length
PL = [pl_A, pl_P];
group = [zeros(1,length(pl_A)), ones(1,length(pl_P))];
figure()
boxplot(PL, group, 'Labels', ...
    {['Active Pulses (n = ', num2str(length(pl_A)), ')'],...
    ['Passive Pulses (n = ', num2str(length(pl_P)), ')']},...
     'DataLim', [0, 3], 'ExtremeMode', 'compress', ...
     'colors', 'k')
ylabel('Pulse Duration [ms]')

