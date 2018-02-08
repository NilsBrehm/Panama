%% Read Call series audio fiels
pathname = '/media/brehm/Data/Panama/DataForPaper/callseries/';
d = dir(pathname);
file_list = d(3:end);
calls = cell(length(file_list),1);

for i = 1:length(file_list)
    calls{i} = audioread([pathname, file_list(i).name]);
end

%%
call_nr = 2;

cs = calls{call_nr};
fs = 480*1000;
t = 0:1/fs:length(cs)/fs;
t(end) = [];
plot(t,cs)
xlim([0, max(t)])
xlabel('time [s]')
