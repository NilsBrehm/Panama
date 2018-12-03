%% Open data
clear
clc
close all

path_linux = '/media/brehm/Data/MasterMoth/batcalls/noisereduced/';
% path_windows = 'D:\Masterarbeit\2018-01-12\Panama\DataForPaper\SeveralSpecies\i pp273 idalus fasciipuncta\';

[file,path] = uigetfile([path_linux, '*.wav'],'select a wav file');
open(fullfile(path,file))
samplingrate = 250 * 1000;
disp(['Sampling Rate: ', num2str(samplingrate/1000), ' kHz'])

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
load('/media/brehm/Data/Panama/Panama/selena_colormap.mat')
% load('D:\Masterarbeit\2018-01-12\Panama\code\Panama\selena_colormap.mat')

% Set Font:
fontfamlily = 'Times';

% Spectrogram and Time Course
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

figname = [path, file(1:end-4), '_Spectrogram', '.png'];
set(gcf, 'Color', 'white')
if save_figs == 1
export_fig(figname,'-m2')
close
end
disp('finished Spectrogram Plot')
