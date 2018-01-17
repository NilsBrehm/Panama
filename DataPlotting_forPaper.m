%% Plotting for paper figures
% Use this to change the path:
% path = 'D:\Masterarbeit\2018-01-12\Panama\DataForPaper\Castur\PK1248\';
% filename = [path, file(1:end-4), '\'];

%% Plotting Parameters
clc
callseries = 0;
save_figs = 1;
if save_figs == 1
    displayfigs = 'off';
else
    displayfigs = 'on';
end

% Load colormap
% load('/media/brehm/Data/Panama/code/Panama/selena_colormap.mat')
load('D:\Masterarbeit\2018-01-12\Panama\code\Panama\selena_colormap.mat')

% Set Font:
fontfamlily = 'Times';

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
    
    pos_fig = [100 100 8 8];
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

%% Spectrogram and Time Course
tt = 0:(1/samplingrate):length(data)/samplingrate;
tt(end) = [];
pos_fig = [100 100 15 9];
fig = figure('Visible', displayfigs);
set(fig, 'Color', 'white', 'Units', 'centimeters', 'position', pos_fig)
subplot(2,1,1)
window_size = 100; % the larger the better the spectral res (temp res goes down)
window = hann(window_size);
%noverlap = round(window_size*0.75);
noverlap = window_size-5;
nfft = 512;
spectrogram(data, window, noverlap, nfft, samplingrate, 'yaxis')
xlim([0, tt(end)*1000])
ylim([0 150])
cl = colorbar('xlim', [-110 -40], 'Fontsize',10', 'FontName', fontfamlily);
cl.Label.String = '[dB/Hz]';
% caxis([-100 -45])
caxis([-100 -45]) % Use this to adjust coloring of spectrak plot
% colorbar off
colormap(c)
box off
set(gca,'xtick',[], 'xlabel', [], 'fontsize', 10, 'FontName', fontfamlily)
ylabel('Frequency [kHz]', 'fontsize', 10, 'FontName', fontfamlily)

subplot(2,1,2)
plot(tt*1000,data,'color', 'black')
xlim([0, tt(end)*1000])
set(gca, 'fontsize', 10, 'FontName', fontfamlily)
xlabel('Time [ms]', 'FontSize', 10, 'FontName', fontfamlily)
ylabel('Amplitude', 'fontsize', 10, 'FontName', fontfamlily)
box off
colorbar('Visible','off')

figname = [filename, 'Spectrogram', '.png'];
set(gcf, 'Color', 'white')
if save_figs == 1
export_fig(figname,'-m2')
close
end
disp('finished Spectrogram Plot')

%% Plot Active and Passive Pulses separately
xlimit = 10;
steps = 0.2;
ymax = round(max(max(max(pulses.active)), max(max(pulses.passive))), 2);
ymin = round(min(min(min(pulses.active)), min(min(pulses.passive))), 2);
tt = 0:(1/samplingrate):length(pulses.active)/samplingrate;
tt(end) = [];

% Active Pulses
pos_fig = [100 100 3 18];
fig = figure('Visible', displayfigs);
set(fig, 'Color', 'white', 'Units', 'centimeters', 'position', pos_fig)
for i = 1:noPulsesA
    subplot(noPulsesA,1,i)
    plot(tt(1:end-xlimit)*1000, pulses.active(1:end-xlimit,i), 'k', 'linewidth', 1)
    set(gca, 'linewidth',1, 'fontsize', 10, 'FontName', fontfamlily)
    xticks(0:steps:tt(end-xlimit)*1000)
    xlim([0 tt(end-xlimit)*1000])
    box off
    set(gca,'ytick',[], 'ylabel', [], 'fontsize', 10, 'FontName', fontfamlily)
    %yticks(-1:1)
    %ylim([-1 1])
%     if i == 1
%         title({'Active Pulses', ' '})
%     end
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
% pos_fig = [100 100 5 40];
fig = figure('Visible', displayfigs);
set(fig, 'Color', 'white', 'Units', 'centimeters', 'position', pos_fig)
passive_puleses_matching = fliplr(pulses.passive); % Match Passives
for i = 1:noPulsesP
    subplot(noPulsesP,1,i)
    plot(tt(1:end-xlimit)*1000, passive_puleses_matching(1:end-xlimit,i), 'k', 'linewidth', 1)
    set(gca, 'linewidth',1, 'fontsize', 10, 'FontName', fontfamlily)
    xticks(0:steps:tt(end-xlimit)*1000)
    xlim([0 tt(end-xlimit)*1000])
    box off
    set(gca,'ytick',[], 'ylabel', [], 'fontsize', 10, 'FontName', fontfamlily)
    %yticks(-1:1)
    %ylim([-1 1])
%     if i == 1
%         title({'Passive Pulses', ' '})
%     end
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

%% Save Data
% save([filename, '.mat'])
% disp('Plotting done and data saved')