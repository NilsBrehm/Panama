%% Open csv file
% Manually
clear
clc
uiopen('/media/brehm/Data/MasterMoth/CallStats/stimuli/naturalmothcalls/results.csv',1)

%% ========================================================================
%--------------------------------------------------------------------------
% SELECT RECORDINGS IF YOU DO NOT WANT TO EXTRACT ALL IN THE CSV
%--------------------------------------------------------------------------
%%
results_backup = results;
recs = {'BCI1062_07x07.wav',
    'aclytia_gynamorpha_24x24.wav',
    'agaraea_semivitrea_07x07.wav',
    'carales_12x12_01.wav',
    'chrostosoma_thoracicum_05x05.wav',
    'creatonotos_01x01.wav',
    'elysius_conspersus_11x11.wav',
    'epidesma_oceola_06x06.wav',
    'eucereon_appunctata_13x13.wav',
    'eucereon_hampsoni_11x11.wav',
    'eucereon_obscurum_14x14.wav',
    'gl005_11x11.wav',
    'gl116_05x05.wav',
    'hypocladia_militaris_09x09.wav',
    'idalu_fasciipuncta_05x05.wav',
    'idalus_daga_18x18.wav',
    'melese_12x12_01_PK1297.wav',
    'neritos_cotes_10x10.wav',
    'ormetica_contraria_peruviana_09x09.wav',
    'syntrichura_12x12.wav'};

%% Find recs that were used as stimuli
idx_used = zeros(height(results), length(recs));
for j = 1:length(recs)
    idx_used(:,j) = results.Recording == recs{j};
end
idx_used = logical(sum(idx_used,2));
results = results(idx_used,:);

%% ========================================================================
%--------------------------------------------------------------------------
% EXTRACTING DATA FROM CSV
%--------------------------------------------------------------------------

%% Find calls
idx = find(table2array(results(:,12)) > 0);
idx = [0; idx];

%%
% PD Median | PD Mad | Freq Median | Freq Mad | MinFreq Meadian | MinFreq Mad |
% MaxFreq Median | MaxFreq Mad | IPI Median | IPI Mad | PulseNumber | CallDuration
% final = cell(length(idx)-1, 1);
final_a = zeros(length(idx)-1, 13);
final_p = zeros(length(idx)-1, 13);

pd_a = [];
pd_a_id = [];
ipi_a_id = [];
freq_a = [];
ipi_a = [];
pnr_a = [];

pd_p = [];
pd_p_id = [];
ipi_p_id = [];
freq_p = [];
ipi_p = [];
pnr_p = [];

ITI = [];

for k=2:1:length(idx)
    % Get single call
    temp_call = results(idx(k-1)+1:idx(k),:);
    % Find active and passive pulses
    idx_a = find(table2array(temp_call(:,8)) == 0);
    idx_p = find(table2array(temp_call(:,8)) == 1);
    
    % Get Data from this call
    % Pulse Duration
    pd_a= [pd_a; table2array(temp_call(idx_a, 3))];
    pd_a_id = [pd_a_id, zeros(1, length(table2array(temp_call(idx_a, 3))))+k-1];
    pd_median_a = median(table2array(temp_call(idx_a, 3)));
    pd_mad_a = mad(table2array(temp_call(idx_a, 3)),1);
    
    % Freq
    freq_a= [freq_a; table2array(temp_call(idx_a, 4))];
    freq_median_a = median(table2array(temp_call(idx_a, 4)));
    freq_mad_a = mad(table2array(temp_call(idx_a, 4)),1);
    
    % Min Freq
    minfreq_median_a = median(table2array(temp_call(idx_a, 5)));
    minfreq_mad_a = mad(table2array(temp_call(idx_a, 5)),1);
    
    % Max Freq
    maxfreq_median_a = median(table2array(temp_call(idx_a, 6)));
    maxfreq_mad_a = mad(table2array(temp_call(idx_a, 6)),1);
    
    %     if freq_median_a == 0
    %         freq_median_a = mean([minfreq_median_a, maxfreq_median_a]);
    %     end
    % IPI
    a_dummy = table2array(temp_call(idx_a, 11));
    a_dummy = a_dummy(1:end-1);
    ipi_a= [ipi_a; a_dummy];
    ipi_a_id = [ipi_a_id, zeros(1, length(a_dummy))+k-1];
    ipi_median_a = median(table2array(temp_call(idx_a, 11)));
    ipi_mad_a = mad(table2array(temp_call(idx_a, 11)),1);
    
    % Pulse Number
    pnr_a = [pnr_a; length(idx_a)];
    
    % Passive Pulses ------------------------------------------------------
    % Pulse Duration
    pd_p= [pd_p; table2array(temp_call(idx_p, 3))];
    pd_p_id = [pd_p_id, zeros(1, length(table2array(temp_call(idx_p, 3))))+k-1];
    pd_median_p = median(table2array(temp_call(idx_p, 3)));
    pd_mad_p = mad(table2array(temp_call(idx_p, 3)),1);
    
    % Freq
    freq_p= [freq_p; table2array(temp_call(idx_p, 4))];
    freq_median_p = median(table2array(temp_call(idx_p, 4)));
    freq_mad_p = mad(table2array(temp_call(idx_p, 4)),1);
    
    % Min Freq
    minfreq_median_p = median(table2array(temp_call(idx_p, 5)));
    minfreq_mad_p = mad(table2array(temp_call(idx_p, 5)),1);
    
    % Max Freq
    maxfreq_median_p = median(table2array(temp_call(idx_p, 6)));
    maxfreq_mad_p = mad(table2array(temp_call(idx_p, 6)),1);
    
    %     if freq_median_p == 0
    %         freq_median_p = mean([minfreq_median_p, maxfreq_median_p]);
    %     end
    % IPI
    p_dummy = table2array(temp_call(idx_p, 11));
    p_dummy = p_dummy(1:end-1);
    ipi_p_id = [ipi_p_id, zeros(1, length(p_dummy))+k-1];
    ipi_p= [ipi_p; p_dummy];
    ipi_median_p = median(table2array(temp_call(idx_p, 11)));
    ipi_mad_p = mad(table2array(temp_call(idx_p, 11)),1);
    
    % Pulse Number
    pnr_p = [pnr_p; length(idx_p)];
    
    % Call Duration
    call_dur = table2array(temp_call(end, 12));
    
    % ITI
    abc = table2array(temp_call(idx_a, 11));
    ITI_dummy = abc(end);
    ITI = [ITI, ITI_dummy];
    %     final{k-1} = [pd_median_a, pd_mad_a, freq_median_a, freq_mad_a, minfreq_median_a, ...
    %         minfreq_mad_a, maxfreq_median_a, maxfreq_mad_a, ipi_median_a, ipi_mad_a, ...
    %         pnr_a, call_dur];
    %
    final_a(k-1, :) = [pd_median_a, pd_mad_a, freq_median_a, freq_mad_a, minfreq_median_a, ...
        minfreq_mad_a, maxfreq_median_a, maxfreq_mad_a, ipi_median_a, ipi_mad_a, ...
        pnr_a(k-1), call_dur, ITI_dummy];
    
    final_p(k-1, :) = [pd_median_p, pd_mad_p, freq_median_p, freq_mad_p, minfreq_median_p, ...
        minfreq_mad_p, maxfreq_median_p, maxfreq_mad_p, ipi_median_p, ipi_mad_p, ...
        pnr_p(k-1), call_dur, ITI_dummy];
end

%% Create final table
idx2 = idx(2:end);
names = table2array(results(idx2,1));

T_a = array2table(final_a,...
    'VariableNames',{'PD','PDmad','Freq','Freqmad','MinFreq','MinFreqmad',...
    'MaxFreq','MaxFreqmad','IPI', 'IPImad', 'PulseNumber', 'CallDuration', 'ITI'});
T_a.Recording = names;

T_p = array2table(final_p,...
    'VariableNames',{'PD','PDmad','Freq','Freqmad','MinFreq','MinFreqmad',...
    'MaxFreq','MaxFreqmad','IPI', 'IPImad', 'PulseNumber', 'CallDuration', 'ITI'});
T_p.Recording = names;

%% SAVE TABLE
writetable(T_a,'/media/brehm/Data/MasterMoth/CallStats_active.txt');
writetable(T_p,'/media/brehm/Data/MasterMoth/CallStats_passive.txt');
disp('Data saved')

%% BoxPlot AvsP
fsize = 10;
axesticks = 9;
subplot(2,3,1)
boxplot(pd_a, pd_a_id, 'PlotStyle', 'traditional','symbol','', 'colors', 'k', 'BoxStyle', 'outline')
hold on
scatter(pd_a_id, pd_a, 5, 'ks', 'filled')
ylim([0, 0.6])
ylabel('Pulse duration [ms]', 'FontSize', fsize, 'FontName', 'Helvectica')
set(gca, 'FontSize', axesticks,'TickDir','out')
grid on
box off

subplot(2,3,2)
boxplot(ipi_a, ipi_a_id, 'PlotStyle', 'traditional','symbol','', 'colors', 'k', 'BoxStyle', 'outline')
hold on
scatter(ipi_a_id, ipi_a, 5, 'ks', 'filled')
ylim([0, 20])
ylabel('Inter pulse interval [ms]', 'FontSize', fsize, 'FontName', 'Helvectica')
set(gca, 'FontSize', axesticks,'TickDir','out')
box off
grid on

subplot(2,3,3)
boxplot(freq_a, pd_a_id, 'PlotStyle', 'traditional','symbol','', 'colors', 'k', 'BoxStyle', 'outline')
hold on
scatter(pd_a_id, freq_a, 5, 'ks', 'filled')
ylim([0, 80])
ylabel('Frequency [kHz]', 'FontSize', fsize, 'FontName', 'Helvectica')
set(gca, 'FontSize', axesticks,'TickDir','out')
box off
grid on

% Passive
subplot(2,3,4)
boxplot(pd_p, pd_p_id, 'PlotStyle', 'traditional','symbol','', 'colors', 'k', 'BoxStyle', 'outline')
hold on
scatter(pd_p_id, pd_p, 5, 'ks', 'filled')
ylim([0, 0.6])
ylabel('Pulse duration [ms]', 'FontSize', fsize, 'FontName', 'Helvectica')
xlabel('Call number', 'FontSize', fsize, 'FontName', 'Helvectica')
set(gca, 'FontSize', axesticks,'TickDir','out')
box off
grid on

subplot(2,3,5)
boxplot(ipi_p, ipi_p_id, 'PlotStyle', 'traditional','symbol','', 'colors', 'k', 'BoxStyle', 'outline')
hold on
scatter(ipi_p_id, ipi_p, 5, 'ks', 'filled')
ylim([0, 20])
ylabel('Inter pulse interval [ms]', 'FontSize', fsize, 'FontName', 'Helvectica')
xlabel('Call number', 'FontSize', fsize, 'FontName', 'Helvectica')
set(gca, 'FontSize', axesticks,'TickDir','out')
box off
grid on

subplot(2,3,6)
boxplot(freq_p, pd_p_id, 'PlotStyle', 'traditional','symbol','', 'colors', 'k', 'BoxStyle', 'outline')
hold on
scatter(pd_p_id, freq_p, 5, 'ks', 'filled')
ylim([0, 80])
ylabel('Frequency [kHz]', 'FontSize', fsize, 'FontName', 'Helvectica')
xlabel('Call number', 'FontSize', fsize, 'FontName', 'Helvectica')
set(gca, 'FontSize', axesticks,'TickDir','out')
box off
grid on
% 
% set(gcf, 'PaperUnits', 'inches');
% x_width = 5.9 ;
% y_width = 2.9;
% set(gcf, 'PaperPosition', [0 0 x_width y_width]);
% saveas(gcf,'/media/brehm/Data/MasterMoth/CallStats/fig1.pdf')
% close all
% fig = gcf;
% fig.PaperUnits = 'inches';
% fig.PaperPosition = [0 0 5.9 2.9];
% print('/media/brehm/Data/MasterMoth/CallStats/fig1','-dpdf')
% close all