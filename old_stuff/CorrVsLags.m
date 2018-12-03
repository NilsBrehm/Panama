%% Correlation Value at zerolag
clear CorrLag0
lagnumber = 0;
for a = 1:noPulsesA
    for p = 1:noPulsesA
        CorrLag0(a,p) = ccAA{a,p}(ccAA{a,p}(:,2) == lagnumber);
    end
end

%% PLOTTING
compare_what = 'AP';

if strcmp(compare_what, 'AP')
    maxcorr = MaxCorr_AP;
    xtitle = 'Passive Pulse Number';
    ytitle = 'Active Pulse Number';
    fname = 'MatrixPlot_AP';
    noPulses1 = noPulsesA;
    noPulses2 = noPulsesP;
elseif strcmp(compare_what, 'AA')
    maxcorr = MaxCorr_AA;
    xtitle = 'Active Pulse Number';
    ytitle = 'Active Pulse Number';
    fname = 'MatrixPlot_AA';
    noPulses1 = noPulsesA;
    noPulses2 = noPulsesA;
elseif strcmp(compare_what, 'PP')
    maxcorr = MaxCorr_PP;
    xtitle = 'Passive Pulse Number';
    ytitle = 'Passive Pulse Number';
    fname = 'MatrixPlot_PP';
    noPulses1 = noPulsesP;
    noPulses2 = noPulsesP;
elseif strcmp(compare_what, 'lag')
    maxcorr = BestLag_AP;
    xtitle = 'Passive Pulse Number';
    ytitle = 'Active Pulse Number';
    fname = 'MatrixPlot_lags_AP';
    noPulses1 = noPulsesA;
    noPulses2 = noPulsesP;
end 

pos_fig = [100 100 25 25];
fig = figure();
set(fig, 'Color', 'white', 'Units', 'centimeters', 'position', pos_fig)
matrix_plot(maxcorr, noPulses1, noPulses2, 'Best Cross Correlation [r]', ...
    xtitle, ytitle,[0, 1]); 
axis equal; xlim([0.5 noPulses2+0.5]); ylim([0.5 noPulses1+0.5]); box off; axis xy;

%% Plot zerolag Correlation  Value
pos_fig = [100 100 25 25];
fig = figure();
set(fig, 'Color', 'white', 'Units', 'centimeters', 'position', pos_fig)
matrix_plot(CorrLag0, noPulsesA, noPulsesP, ['Correlation at lag ', num2str(lagnumber)], ...
    xtitle, ytitle, [0, 1]); 
axis equal; xlim([0.5 noPulses2+0.5]); ylim([0.5 noPulses1+0.5]); box off; axis xy;

%% Plot Best Lags
pos_fig = [100 100 25 25];
fig = figure();
set(fig, 'Color', 'white', 'Units', 'centimeters', 'position', pos_fig)
matrix_plot(BestLag_AA, noPulsesA, noPulsesP, 'Best Lag', ...
    xtitle, ytitle); 
axis equal; xlim([0.5 noPulses2+0.5]); ylim([0.5 noPulses1+0.5]); box off; axis xy;

