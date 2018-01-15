%% Get number of calls in directory
clear
clc
pathname = '/media/brehm/Data/Panama/DataForPaper/Castur/PK1285/Pk12850014/';
d = dir(pathname);
dirFlags = [d.isdir];
folders = d(dirFlags);
number_of_calls = length(folders) - 2;

%%
callstats = table();
for i = 1:number_of_calls
    filename = [pathname, 'call_nr_', num2str(i), '/call_stats.xls'];
    a = readtable(filename);
    callstats = [callstats; a];
end

%% Save to HDD
writetable(callstats, [pathname, 'call_stats.xls'])
disp('Call Stats saved!')
