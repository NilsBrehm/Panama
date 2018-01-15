%%
clear
clc
PK1285_A = [];
PK1285_P = [];
%%
for i = 1:11
    if i <10
        data_name = ['PK1285/all/0', num2str(i), '.mat'];
    else
        data_name = ['PK1285/all/', num2str(i), '.mat'];
    end
    path_name = ['/media/brehm/Data/Meeting/Carales/', data_name];
    A = load(path_name, 'IPIs', 'A_IPIs', 'P_IPIs', 'ITI',...
        'noPulsesA', 'noPulsesP');
    
    PK1285_A = [PK1285_A, A.A_IPIs];
    PK1285_P = [PK1285_P, A.P_IPIs];
    
end
%%
clc
PK1285_A_MeanIPI(1) = median(PK1285_A);
PK1285_A_MeanIPI(2) = std(PK1285_A)/length(PK1285_A); % Standard Error

PK1285_P_MeanIPI(1) = median(PK1285_P);
PK1285_P_MeanIPI(2) = std(PK1285_P)/length(PK1285_P);

disp('Active: Mean IPI')
disp(PK1285_A_MeanIPI)
disp('Passive: Mean IPI')
disp(PK1285_P_MeanIPI)

%% histogram
figure()
histogram(PK1285_A(PK1285_A<5), 10)
figure()
histogram(PK1285_P(PK1285_P<5), 10)

%% ttest and Wilcoxon rank sum test
[v, p_t] = ttest2(PK1285_A, PK1285_P);
[p,h,stats] = ranksum(PK1285_A, PK1285_P);