%% Maximal overlap discrete wavelet transform
NumApulses = size(pulses.active, 2);
NumPpulses = size(pulses.passive, 2);
wA = cell(NumApulses);
wP = cell(NumPpulses);

for i = 1:NumApulses
wA{i} = modwt(pulses.active(:, i),'fk14',5);
end
for i = 1:NumPpulses
wP{i} = modwt(pulses.passive(:, i),'fk14',5);
end

%% Wavelet Cross-Correlation
lev = 3;
for a = 1:NumApulses
    for p = 1:NumPpulses
        [APXC{a,p},~,APLAGS{a,p}] = modwtxcorr(wA{a},wP{p},'fk14');
        MaxWCorr_AP(a,p) = max(abs(APXC{a,p}{lev}));
    end
end
for a = 1:NumApulses
    for p = 1:NumApulses
        [AAXC{a,p},~,AALAGS{a,p}] = modwtxcorr(wA{a},wA{p},'fk14');
        MaxWCorr_AA(a,p) = max(abs(AAXC{a,p}{lev}));
    end
end
for a = 1:NumPpulses
    for p = 1:NumPpulses
        [PPXC{a,p},~,PPLAGS{a,p}] = modwtxcorr(wP{a},wP{p},'fk14');
        MaxWCorr_PP(a,p) = max(abs(PPXC{a,p}{lev}));
    end
end

%% PLOTTING
compare_what = 'AP';

if strcmp(compare_what, 'AP')
    maxcorr = MaxWCorr_AP;
    xtitle = 'Passive Pulse Number';
    ytitle = 'Active Pulse Number';
    fname = 'MatrixPlot_AP';
    noPulses1 = NumApulses;
    noPulses2 = NumPpulses;
elseif strcmp(compare_what, 'AA')
    maxcorr = MaxWCorr_AA;
    xtitle = 'Active Pulse Number';
    ytitle = 'Active Pulse Number';
    fname = 'MatrixPlot_AA';
    noPulses1 = NumApulses;
    noPulses2 = NumApulses;
elseif strcmp(compare_what, 'PP')
    maxcorr = MaxWCorr_PP;
    xtitle = 'Passive Pulse Number';
    ytitle = 'Passive Pulse Number';
    fname = 'MatrixPlot_PP';
    noPulses1 = NumPpulses;
    noPulses2 = NumPpulses;
end 

pos_fig = [100 100 25 25];
fig = figure();
set(fig, 'Color', 'white', 'Units', 'centimeters', 'position', pos_fig)
matrix_plot(maxcorr, noPulses1, noPulses2, 'Best Cross Correlation [r]', ...
    xtitle, ytitle,[0, 1]); 
axis equal; xlim([0.5 noPulses2+0.5]); ylim([0.5 noPulses1+0.5]); box off; axis xy;

%%
% %% Plot Cross Correlation Function
% xc = XC{1,1};
% lags = LAGS{1,1};
% lev = 4;
% zerolag = floor(numel(xc{lev})/2+1);
% tlag = lags{lev}(zerolag-10:zerolag+10).*(1/samplingrate);
% figure;
% plot(tlag,xc{lev}(zerolag-10:zerolag+10));
% title(['Wavelet Cross-Correlation Sequence (level ', num2str(lev), ')' ]);
% xlabel('Time')
% ylabel('Cross-Correlation Coefficient');
