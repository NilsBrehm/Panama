%% Open csv file
% Manually

%%
% Find calls
idx = find(table2array(results(:,12)) > 0);
idx = [0; idx];

%%
% PD Median | PD Mad | Freq Median | Freq Mad | MinFreq Meadian | MinFreq Mad | 
% MaxFreq Median | MaxFreq Mad | IPI Median | IPI Mad | PulseNumber | CallDuration
% final = cell(length(idx)-1, 1);
final_a = zeros(length(idx)-1, 12);
final_p = zeros(length(idx)-1, 12);
pd_a = [];
pd_a_id = [];
freq_a = [];
ipi_a = [];

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
    
    if freq_median_a == 0
        freq_median_a = mean([minfreq_median_a, maxfreq_median_a]);
    end
    % IPI
    ipi_a= [ipi_a; table2array(temp_call(idx_a, 11))];
    ipi_median_a = median(table2array(temp_call(idx_a, 11)));
    ipi_mad_a = mad(table2array(temp_call(idx_a, 11)),1);
    
    % Pulse Number
    pnr_a = length(idx_a);
    
    % Passive Pulses
    % Pulse Duration
    pd_median_p = median(table2array(temp_call(idx_p, 3)));
    pd_mad_p = mad(table2array(temp_call(idx_p, 3)),1);
    
    % Freq
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
    ipi_median_p = median(table2array(temp_call(idx_p, 11)));
    ipi_mad_p = mad(table2array(temp_call(idx_p, 11)),1);
    
    % Pulse Number
    pnr_p = length(idx_p);
   
    % Call Duration
    call_dur = table2array(temp_call(end, 12));
    
%     final{k-1} = [pd_median_a, pd_mad_a, freq_median_a, freq_mad_a, minfreq_median_a, ...
%         minfreq_mad_a, maxfreq_median_a, maxfreq_mad_a, ipi_median_a, ipi_mad_a, ...
%         pnr_a, call_dur];
%     
    final_a(k-1, :) = [pd_median_a, pd_mad_a, freq_median_a, freq_mad_a, minfreq_median_a, ...
        minfreq_mad_a, maxfreq_median_a, maxfreq_mad_a, ipi_median_a, ipi_mad_a, ...
        pnr_a, call_dur];
    
    final_p(k-1, :) = [pd_median_p, pd_mad_p, freq_median_p, freq_mad_p, minfreq_median_p, ...
        minfreq_mad_p, maxfreq_median_p, maxfreq_mad_p, ipi_median_p, ipi_mad_p, ...
        pnr_p, call_dur];
end

%% Create final table
idx2 = idx(2:end);
names = table2array(results(idx2,1));

T_a = array2table(final_a,...
    'VariableNames',{'PD','PDmad','Freq','Freqmad','MinFreq','MinFreqmad',...
    'MaxFreq','MaxFreqmad','IPI', 'IPImad', 'PulseNumber', 'CallDuration'});
T_a.Recording = names;

T_p = array2table(final_p,...
    'VariableNames',{'PD','PDmad','Freq','Freqmad','MinFreq','MinFreqmad',...
    'MaxFreq','MaxFreqmad','IPI', 'IPImad', 'PulseNumber', 'CallDuration'});
T_p.Recording = names;

%%
writetable(T_a,'/media/brehm/Data/MasterMoth/CallStats_active.txt');
writetable(T_p,'/media/brehm/Data/MasterMoth/CallStats_passive.txt');

%% BoxPlot
boxplot(freq_a, pd_a_id, 'PlotStyle', 'compact','OutlierSize',1)