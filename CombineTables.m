%% This script puts all the results from one recording into one table
%Load csv files
clear
clc
close all
base_path = '/media/brehm/Data/Panama/DataForPaper/Lophocampa/';
species = '9488';
species_path = [base_path, species, '/'];

listing = dir(species_path);
recs = {};
count = 1;
for i = 3:length(listing)
    if strcmp(listing(i).name(1), 'P')
        recs{count} = listing(i).name;
        count = count + 1;
    end
end

%% Put results from all recordings in one table
R = [];
for k = 1:length(recs)
   pp = [species_path, recs{k}, '/results.csv'];
   M = import_csv(pp);
   R = [R; M];
end

%% Save to csv
writetable(R, [species_path, species, '_allresults.csv'])
disp('All Data Saved')