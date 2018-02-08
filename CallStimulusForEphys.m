%% Create Call Stimulus for Ephys
% Befor using this you need to cut out the desired stimulus from the
% recording and align the first pulse to time zero. The name must be
% 'call'.
%
% Copyright Nils Brehm 2018

%% Plot raw data
figure()
plot(data)
set(gcf, 'position', [500 500 1000 800])

samplingrate = 480*1000;

%%
close all

call = data(a1.DataIndex:a2.DataIndex);
% Settings

audio_name = 'eucereon_appunctata_11x11';
save_stim = true;
filter_on = true;

% -------------------------------------------------------------------------

fs = samplingrate;
audio_path = '/media/brehm/Data/MasterMoth/stimuli/';

disp(['Sampling Rate = ', num2str(fs/1000)])
displayfigs = 'off';
% -------------------------------------------------------------------------
tail = 0.1 * fs;
call_stim = [call; zeros(tail, 1)];  % add 100 ms pause
if filter_on
    highpass = true;
    lowpass = false;
    a = call_stim;
    call_stim = bandpassfilter_data(call_stim, 2000, 150*1000, 2, fs, highpass, lowpass);
    disp('recording filtered')
end
t = 0:1/fs:length(call_stim)/fs;
t(end) = [];

plot(t, a)
hold on
plot(t, call_stim)
xlim([0, max(t)])
xlabel('time [s]')
pause(1)
%% Periodogram
% [p1, f1] = periodogram(a,[],[],fs,'power');
% [p2, f2] = periodogram(call_stim,[],[],fs,'power');
% 
% plot(f1,p1,'k')
% hold on
% plot(f2,p2,'r')

%%
% save as wav file
if save_stim
    audiowrite([audio_path, audio_name, '.wav'], call_stim , fs);
    disp('Stimulus saved as wav file')
end

%% Spectrogram and Time Course
if save_stim
    close all
    load('/media/brehm/Data/Panama/code/Panama/selena_colormap.mat')
    pos_fig = [100 100 15 9];
    fig = figure('Visible', displayfigs);
    set(fig, 'Color', 'white', 'Units', 'centimeters', 'position', pos_fig)
    window_size = 100; % the larger the better the spectral res (temp res goes down)
    window = hann(window_size);
    noverlap = window_size-5;
    nfft = 512;
    spectrogram(call_stim(1:end-tail), window, noverlap, nfft, fs, 'yaxis')
    % xlim([0, tt(end)*1000])
    ylim([0 150])
    cl = colorbar('xlim', [-110 -40], 'Fontsize',10');
    cl.Label.String = '[dB/Hz]';
    caxis([-100 -45]) % Use this to adjust coloring of spectrak plot
    colormap(c)
    box off
    ylabel('Frequency [kHz]', 'fontsize', 10)
    
    figname = [audio_path, audio_name, '.png'];
    
    export_fig(figname,'-m2')
    disp('saved spectrogram')
    close all
end
