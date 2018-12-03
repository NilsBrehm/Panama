function compute_spectrogram(data, samplingrate, P1)
% This function computes a spectorgram in the style of 'Selena'
% 
% Copyright Nils Brehm 2018

% Spectrogram and Time Course
% Load colormap
load('/media/brehm/Data/Panama/code/Panama/selena_colormap.mat')
window_size = ceil(length(data)/2); % the larger the better the spectral res (temp res goes down)
window = hann(window_size);
noverlap = window_size-1;
nfft = 512;
spectrogram(data, window, noverlap, nfft, samplingrate, 'xaxis', 'power')
colorbar off
xlim([0 200])
cl = colorbar('northoutside','xlim', [min(P1)+10 max(P1)+10]);
%cl = colorbar('xlim', [-80 -30]);
cl.Label.String = '[dB]';
caxis([min(P1)+10 max(P1)+10]) % Use this to adjust coloring of spectrak plot
%caxis([-80 -30])
colormap(c)
box off
%disp([min(P1), max(P1)])
% disp(window_size)

end