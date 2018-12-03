%% Plotting Parameters
callseries = 0;
save_figs = 1;
if save_figs == 1
    displayfigs = 'off';
else
    displayfigs = 'on';
end

% Load colormap
load('/media/brehm/Data/Panama/selena_colormap.mat')
% Set Font:
fontfamlily = 'Times';

%% Cut recording into single calls if neccessary
if callseries == 1
    calls= cell(2,length(pulsenumber));
    
    for i = 1:length(pulsenumberA)
        calls{1, i} = pulses.active(:, pulsenumberA(i, 1):pulsenumberA(i, 2));
    end
    
    for i = 1:length(pulsenumberA)
        calls{2, i} = pulses.passive(:, pulsenumberP(i, 1):pulsenumberP(i, 2));
    end
    
end
%% MATRIX PLOTs
%% Use this for single calls:
modes = {'AP'; 'AA'; 'PP'};
for k = 1:length(modes)
    compare_what = modes{k};
    if strcmp(compare_what, 'AP')
        maxcorr = MaxCorr_AP;
        xtitle = 'Passive Pulse Number';
        ytitle = 'Active Pulse Number';
        fname = 'MatrixPlot_AP';
        noPulses1 = noPulsesA;
        noPulses2 = noPulsesP;
    elseif strcmp(compare_what, 'AA')
        maxcorr = MaxCorr_AA;
        xtitle = 'Active Pulse Number';
        ytitle = 'Active Pulse Number';
        fname = 'MatrixPlot_AA';
        noPulses1 = noPulsesA;
        noPulses2 = noPulsesA;
    elseif strcmp(compare_what, 'PP')
        maxcorr = MaxCorr_PP;
        xtitle = 'Passive Pulse Number';
        ytitle = 'Passive Pulse Number';
        fname = 'MatrixPlot_PP';
        noPulses1 = noPulsesP;
        noPulses2 = noPulsesP;
    end
    
    pos_fig = [100 100 10 10];
    fig = figure('Visible', displayfigs);
    set(fig, 'Color', 'white', 'Units', 'centimeters', 'position', pos_fig)
    matrix_plot(maxcorr, noPulses1, noPulses2, 'Max. Cross Correlation [r]', ...
        xtitle, ytitle, [0, 1]);
    axis equal; xlim([0.5 noPulses2+0.5]); ylim([0.5 noPulses1+0.5]); box off; axis xy;
    figname = [filename, fname, '.png'];
    if save_figs == 1
        export_fig(figname, '-r300', '-q101')
        close
    end
    disp(['finished ', fname])
end

%% Use this if recording contains several calls:
if callseries == 1
    for i = 1:length(pulsenumber)
        corrs = MaxCorr_AP(pulsenumberA(i,1):pulsenumberA(i,2), pulsenumberP(i,1):pulsenumberP(i,2));
        nomPulsesA = size(corrs, 1);
        nomPulsesP = size(corrs, 2);
        pos_fig = [100 100 25 25];
        fig = figure('Visible', displayfigs);
        set(fig, 'Color', 'white', 'Units', 'c entimeters', 'position', pos_fig)
        matrix_plot(corrs, nomPulsesA,nomPulsesP, 'Cross Correlation: Raw Pulses',...
            'Best Cross Correlation [r]','Passive Pulse Number', 'Active Pulse Number',...
            [0, 1]); axis equal; xlim([0.5 nomPulsesP+0.5]); ylim([0.5 nomPulsesA+0.5]); box off; axis xy;
        figname = [path, file(1:end-4), '/MatrixPlot_Corr_AP_CALL_', num2str(i), '.png'];
        if save_figs == 1
            export_fig(figname, '-r300', '-q101')
            close
        end
    end
end


%% Plot whole call
% With Time Axis:
fig = figure('Visible', displayfigs);
tt = 0:(1/samplingrate):length(data)/samplingrate;
tt(end) = [];
figure('units','normalized','outerposition',[0 0 1 1], 'Visible', displayfigs);
set(gcf, 'Color', 'white')
plot(tt*1000,data,'color', 'black')
xlabel('time [ms]')
ylabel('Amplitude')
xlim([0, tt(end)*1000])
figname = [filename, 'WholeCall', '.png'];
if save_figs == 1
export_fig(figname,'-m2')
close
end
disp('finished: Whole Call Plot')

%% Spectrogram and Time Course
pos_fig = [100 100 15 9];
fig = figure('Visible', displayfigs);
set(fig, 'Color', 'white', 'Units', 'centimeters', 'position', pos_fig)
subplot(2,1,1)
window_size = 80;
window = hann(window_size);
%noverlap = round(window_size*0.75);
noverlap = window_size-5;
nfft = 512;
spectrogram(data, window, noverlap, nfft, 480000, 'yaxis')
xlim([0, tt(end)*1000])
ylim([0 150])
cl = colorbar('xlim', [-110 -40], 'Fontsize',10', 'FontName', fontfamlily);
cl.Label.String = '[dB/Hz]';
caxis([-100 -45])
% colorbar off
colormap(c)
box off
set(gca,'xtick',[], 'xlabel', [], 'fontsize', 10, 'FontName', fontfamlily)
ylabel('Frequency [kHz]', 'fontsize', 10, 'FontName', fontfamlily)

subplot(2,1,2)
tt = 0:(1/samplingrate):length(data)/samplingrate;
tt(end) = [];
plot(tt*1000,data,'color', 'black')
xlim([0, tt(end)*1000])
set(gca, 'fontsize', 10, 'FontName', fontfamlily)
xlabel('Time [ms]', 'FontSize', 10, 'FontName', fontfamlily)
ylabel('Frequency [kHz]', 'fontsize', 10, 'FontName', fontfamlily)
box off
colorbar('Visible','off')

figname = [filename, 'Spectrogram', '.png'];
set(gcf, 'Color', 'white')
if save_figs == 1
export_fig(figname,'-m2')
close
end
disp('finished Spectrogram Plot')

%% Use this if recording contains several calls: Spectrogram and Time Course
if callseries == 1
for i = 1:length(callstarts)
    pause(2)
    close
    dd = data(callstarts(i):callends(i));
    tt = 0:(1/samplingrate):length(dd)/samplingrate;
    tt(end) = [];
    xlimit = tt(end)*1000;
    fig = figure('Visible', displayfigs);
    subplot(2,1,1)
    spectrogram(dd, 50, 40, 480, samplingrate, 'yaxis')
    ylim([0, 150])
    xlim([0, xlimit])
%     xticks(0:20:xlimit)
    colorbar off

    subplot(2,1,2)
    plot(tt*1000, dd,'color', 'black')
    %set(gca, 'xlim', [0 limitx]);
    xlim([0, xlimit])
%     xticks(0:20:xlimit)
    xlabel('time [ms]')
    ylabel('Amplitude')
    box off

    
    figname = [filename, 'Spectrogram_call_', num2str(i), '.png'];
    set(gcf, 'Color', 'white')
    if save_figs == 1
        export_fig(figname,'-m2')
        close
    end
end
end

%% Plot Marked Active and Passive Pulses
figure('Visible', displayfigs);
time = 1:length(data);
plot(data, 'k')
hold on
for i = 1:noPulsesA
    plot(time(samples.active(i):samples.active(i)+100), data(samples.active(i):samples.active(i)+100), 'r')
end
hold on
for i = 1:noPulsesP
    plot(time(samples.passive(i):samples.passive(i)+100), data(samples.passive(i):samples.passive(i)+100), 'b')
end

figname = [filename, '_MarkedPulses', '.png'];
set(gcf, 'Color', 'white')
if save_figs == 1
export_fig(figname,'-m2')
close
end
disp('finished Marked plot')

%% Plot all active and passive pulses in comparison: Works only for A=P
if noPulsesA == noPulsesP
    pos_fig = [100 100 15 40];
    fig = figure('Visible', displayfigs);
    set(fig, 'Color', 'white', 'Units', 'centimeters', 'position', pos_fig)
    ymax = round(max(max(max(pulses.active)), max(max(pulses.passive))), 1);
    ymin = round(min(min(min(pulses.active)), min(min(pulses.passive))), 1);
    k = 0;
    j = noPulses+1;
    for i = 1:2:noPulses*2
        k = k+1;
        j = j-1;
        subplot(noPulses,2,i)
        tt = 0:(1/samplingrate):length(pulses.active(:,k))/samplingrate;
        tt(end) = [];
        plot(tt*1000, pulses.active(:,k), 'k', 'linewidth', 1)
        set(gca, 'linewidth',1)
        xticks(0:.1:tt(end)*1000)
        box off
        yticks(ymin:ymax)
        ylim([ymin ymax])
        if k<noPulses
            set(gca,'XTickLabel',[]);
        else
            xlabel('time [ms]')
        end
        subplot(noPulses,2,i+1)
        tt = 0:(1/samplingrate):length(pulses.passive(:,k))/samplingrate;
        tt(end) = [];
        plot(tt*1000, pulses.passive(:,j), 'k', 'linewidth', 1)
        set(gca, 'linewidth',1)
        box off
        xticks(0:.1:tt(end)*1000)
        yticks(ymin:ymax)
        ylim([ymin ymax])
        if k<noPulses
            set(gca,'XTickLabel',[]);
        else
            xlabel('time [ms]')
        end
    end
    figname = [filename, '_ComparePulses', '.png'];
    if save_figs == 1
        export_fig(figname,'-m2')
        close
    end
    disp('finished Compare Pulses Plots')
end

%% Plot Active and Passive Pulses separately
xlimit = 50;
ymax = round(max(max(max(pulses.active)), max(max(pulses.passive))), 2);
ymin = round(min(min(min(pulses.active)), min(min(pulses.passive))), 2);
tt = 0:(1/samplingrate):length(pulses.active)/samplingrate;
tt(end) = [];

% Active Pulses
pos_fig = [100 100 5 40];
fig = figure('Visible', displayfigs);
set(fig, 'Color', 'white', 'Units', 'centimeters', 'position', pos_fig)
for i = 1:noPulsesA
    subplot(noPulsesA,1,i)
    plot(tt*1000, pulses.active(:,i), 'k', 'linewidth', 1)
    set(gca, 'linewidth',1, 'fontsize', 10, 'FontName', fontfamlily)
    xticks(0:.05:tt(end-xlimit)*1000)
    xlim([0 tt(end-xlimit)*1000])
    box off
    yticks(-1:1)
    ylim([-1 1])
    if i == 1
        title('Active Pulses')
    end
    if i<noPulsesA
        set(gca,'XTickLabel',[], 'fontsize', 10, 'FontName', fontfamlily);
    else
        xlabel('Time [ms]', 'fontsize', 12, 'FontName', fontfamlily)
    end
end
figname = [filename, '_Apulses', '.png'];
if save_figs == 1
export_fig(figname,'-m2')
close
end

% Passive Pulses matching with Acive Pulses
pos_fig = [100 100 5 40];
fig = figure('Visible', displayfigs);
set(fig, 'Color', 'white', 'Units', 'centimeters', 'position', pos_fig)
passive_puleses_matching = fliplr(pulses.passive); % Match Passives
for i = 1:noPulsesP
    subplot(noPulsesP,1,i)
    plot(tt*1000, passive_puleses_matching(:,i), 'k', 'linewidth', 1)
    set(gca, 'linewidth',1, 'fontsize', 10, 'FontName', fontfamlily)
    xticks(0:.05:tt(end-xlimit)*1000)
    xlim([0 tt(end-xlimit)*1000])
    box off
    yticks(-1:1)
    ylim([-1 1])
    if i == 1
        title('Passive Pulses')
    end
    if i<noPulsesP
        set(gca,'XTickLabel',[]);
    else
        xlabel('Time [ms]', 'fontsize', 12, 'FontName', fontfamlily)
    end
end

figname = [filename, '_Ppulses', '.png'];
if save_figs == 1
export_fig(figname,'-m2')
close
end
disp('finished Pulses Plots')

%%
disp('done')

%% Save Data
save([filename, '.mat'])
disp('data saved')
%% JUNKYARD

%% Raw Pulses Comparison
% for k = 1:size(pulses.active,2)
%     fig = figure('Visible', displayfigs);
%     for i = 1:size(pulses.passive,2)
%         subplot(5,4,i)
%         plot(-pulses.passive(:,i),'k','linewidth',2)
%         hold on
%         plot(pulses.active(:,k),'r','linewidth',2)
%         title(['P', num2str(i)])
%         ylim([-1,1])
%     end
%     pos_fig = [0 0 1920 1080];
%     set(fig,'Position',pos_fig, 'Color', 'white')
%     suptitle(['A', num2str(k)])
%     if save_figs == 1
%         if k <= 9
%             dummyname = ['0', num2str(k)];
%         else
%             dummyname = num2str(k);
%         end
%         figname = [filename, 'TemporalComparison_A', dummyname, '.png'];
%         export_fig(figname,'-m2')
%         close
%     end
% end
% 
% disp('DONE')

%% Spectral Comparison
% specA = abs(fft(pulses.active));
% specP = abs(fft(-pulses.passive));
% 
% for k = 1:size(pulses.active,2)
%     fig = figure('Visible', displayfigs);
%     for i = 1:size(pulses.passive,2)
%         subplot(5,4,i)
%         plot(specP(:,i),'k','linewidth',2)
%         hold on
%         plot(specA(:,k),'r','linewidth',2)
%         title(['P', num2str(i)])
%         %ylim([-1,1])
%     end
%     pos_fig = [0 0 1920 1080];
%     set(fig,'Position',pos_fig, 'Color', 'white')
%     suptitle(['A', num2str(k)])
%     if save_figs == 1
%         if k <= 9
%             dummyname = ['0', num2str(k)];
%         else
%             dummyname = num2str(k);
%         end
%         figname = [filename, 'SpectralComparison_A', dummyname, '.png'];
%         export_fig(figname,'-m2')
%         close
%     end
% end
% 
% disp('DONE')

%% Plots for Fitted Data
% % Correlation Raw Pulses
% figure('Visible', displayfigs)
% matrix_plot(MaxCorr_FIT_raw, noPulses, 'Cross Correlation: Fitted Pulses', 'Max. Correlation', [0, 1]);
% figname = [filename, '_MatrixPlot_Corr_FIT_raw', '.png'];
% if save_figs == 1
% export_fig(figname,'-m2')
% close
% end
% 
% % MSE
% figure('Visible', displayfigs)
% matrix_plot(minMSE_FIT_raw, noPulses, 'MSE: Fitted Pulses', 'Min. Mean Squared Error');
% figname = [filename, '_MatrixPlot_MSE', '.png'];
% if save_figs == 1
% export_fig(figname,'-m2')
% close
% end

% % Plot Raw crosscorrelation vs lags for all comparisons
% figure('units','normalized','outerposition',[0 0 1 1], 'Visible', displayfigs);
% plot_xcorr(FIT_a, BestLag_FIT_raw, MaxCorr_FIT_raw, crosscorrelation_FIT_raw, noPulses)
% if save_figs == 1
% figname = [filename, '_CrossCorrelations_raw', '.png'];
% export_fig(figname,'-m2')
% close
% end

% % Fitte pulses
% figure('units','normalized','outerposition',[0 0 1 1], 'Visible', displayfigs);
% plot_raw_pulses(FIT_a, FIT_p, MaxCorr_FIT_raw, minMSE_FIT_raw, 1)
% figname = [filename, '_RawPulses_FIT_compared', '.png'];
% if save_figs == 1
% export_fig(figname,'-m2')
% close
% end


% % Plot alignment (shift with lag that yields min. MSE)
% figure('units','normalized','outerposition',[0 0 1 1], 'Visible', displayfigs);
% p = 1;
% for ii = 1:noPulses
%     for jj = 1:noPulses
%         subplot(noPulses,noPulses,p)
%         plot(P1(windowstart:windowend, ii))
%         hold on;
%         plot(circshift(P2(windowstart:windowend, jj), shift_raw(ii,jj)))
%         ylim([min(min(P1)), max(max(P1))])
%         if min(minMSE_raw(ii,:)) == minMSE_raw(ii,jj)
%             textcolor1 = 'red';
%         else
%             textcolor1 = 'black';
%         end
%         text(round(length(windowstart:windowend)/4),round(max(max(P1)-0.1),1)...
%             , ['MSE = ', num2str(round(minMSE_raw(ii, jj), 3))], 'color', textcolor1)
%         p = p+1;
%     end
% end
% if save_figs == 1
% figname = [filename, '_Shifted_MSE', '.png'];
% export_fig(figname,'-m2')
% close
% end

% % Plot Raw crosscorrelation vs lags for all comparisons
% figure('units','normalized','outerposition',[0 0 1 1], 'Visible', displayfigs);
% plot_xcorr(P1, BestLag_raw, MaxCorr_raw, crosscorrelation_raw, noPulses)
% if save_figs == 1
% figname = [filename, '_CrossCorrelations_raw', '.png'];
% export_fig(figname,'-m2')
% close
% end
% 
% % Plot Envelope crosscorrelation vs lags for all comparisons
% figure('units','normalized','outerposition',[0 0 1 1], 'Visible', displayfigs);
% plot_xcorr(E1, BestLag_envs, MaxCorr_envs, crosscorrelation_envs, noPulses)
% if save_figs == 1
% figname = [filename, '_CrossCorrelations_envs', '.png'];
% export_fig(figname,'-m2')
% close
% end
% 
% % Plot Spectral crosscorrelation vs lags for all comparisons
% figure('units','normalized','outerposition',[0 0 1 1], 'Visible', displayfigs);
% plot_xcorr(P1, BestLag_spc, MaxCorr_spc, crosscorrelation_spc, noPulses)
% if save_figs == 1
% figname = [filename, '_CrossCorrelations_spc', '.png'];
% export_fig(figname,'-m2')
% close
% end

% % Correlation Envelope
% fig = figure('Visible', displayfigs);
% set(fig,'Position',pos_fig, 'Color', 'white')
% matrix_plot(MaxCorr_envs, noPulses, 'Cross Correlation: Envelope', 'Min. Mean Squared Error', labelx, labely, [0, 1]);
% figname = [filename, 'MatrixPlot_Corr_envs', '.png'];
% if save_figs == 1
% export_fig(figname,'-m2')
% close
% end
% 
% % Phase Coherence
% fig = figure('Visible', displayfigs);
% set(fig,'Position',pos_fig, 'Color', 'white')
% phase_coherence = ph_coh(PH1, PH2, windowstart, windowend);
% matrix_plot(phase_coherence, noPulses, 'Phase Coherence', 'Correlation', labelx, labely, [0, 1]);
% figname = [filename, 'MatrixPlot_PHC', '.png'];
% if save_figs == 1
% export_fig(figname,'-m2')
% close
% end
% 
% % Correlation Spectral
% fig = figure('Visible', displayfigs);
% set(fig,'Position',pos_fig, 'Color', 'white')
% matrix_plot(MaxCorr_spc, noPulses, 'Cross Corr: Spectral', 'Correlation', labelx, labely, [0, 1]);
% figname = [filename, 'MatrixPlot_SPC', '.png'];
% if save_figs == 1
% export_fig(figname,'-m2')
% close
% end

% % MSE
% figure('Visible', displayfigs)
% matrix_plot(minMSE_raw, noPulses, 'MSE: Raw Pulses', 'Min. Mean Squared Error', labelx, labely);
% figname = [filename, '_MatrixPlot_MSE', '.png'];
% if save_figs == 1
% export_fig(figname,'-m2')
% close
% end

% Correlation Raw Pulses
% pos_fig = [0 0 1080 1080];
% fig = figure('Visible', displayfigs);
% set(fig,'Position',pos_fig, 'Color', 'white')
% matrix_plot(MaxCorr_raw, noPulses, 'Cross Correlation: Raw Pulses', 'Max. Correlation',labelx, labely, [0, 1]);
% figname = [filename, 'MatrixPlot_Corr_raw', '.png'];
% if save_figs == 1
% export_fig(figname)
% close
% end