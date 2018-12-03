samplingrate = 480000;
pulse1_start_time = pulse1_start.DataIndex/samplingrate;
pulse1_end_time = pulse1_end.DataIndex/samplingrate;

pulse2_start_time = pulse2_start.DataIndex/samplingrate;
pulse2_end_time = pulse2_end.DataIndex/samplingrate;

pulse3_start_time = pulse3_start.DataIndex/samplingrate;
pulse3_end_time = pulse3_end.DataIndex/samplingrate;

pulse4_start_time = pulse4_start.DataIndex/samplingrate;
pulse4_end_time = pulse4_end.DataIndex/samplingrate;

%%
pulselength1 = (pulse1_end_time - pulse1_start_time)*1000; % in ms
pulselength2 = (pulse2_end_time - pulse2_start_time)*1000; % in ms
pulselength3 = (pulse3_end_time - pulse3_start_time)*1000; % in ms
pulselength4 = (pulse4_end_time - pulse4_start_time)*1000; % in ms



pulselength_mean = mean([pulselength1, pulselength2, pulselength3, pulselength4])

ipi = diff([pulse1_start_time, pulse2_start_time, pulse3_start_time, pulse4_start_time]) *1000
