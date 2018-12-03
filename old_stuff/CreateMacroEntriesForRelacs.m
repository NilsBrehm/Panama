% Create macros entries for relacs
clc
for i = 1:length(stims)
    text = ['SingleStimulus: stimfile=naturalmothcalls/', stims(i).name,...
        '; waveform=From file; type=Wave; stimscale=true; stimampl=1; intensity=$intensity; duration=0; pause=10ms; ramp=0ms;side = $side; repeats = $repeats;carrierfreq = $carrierfreq;'];
    disp(text)
end
