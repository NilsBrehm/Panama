samplingrate = 480 * 1000;
part = data(q8.DataIndex:q9.DataIndex);

audio_path = [path, file(1:end-4)];
mkdir(audio_path);

audiowrite([audio_path, '\part_08','.wav'],part ,samplingrate)
