% Play moth calls
FS = 44100;
call = audioplayer([data; data], FS);
play(call);

%% Save as wav
FS = 44100;
FS = 22050;
audio_path = '/media/brehm/Data/Panama/AudioExamples';
audiowrite([audio_path, '/eucereeon2.wav'], data, FS)