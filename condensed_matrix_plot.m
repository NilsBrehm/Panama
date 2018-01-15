% condensed matrix plot

P1 = [pulses1.active, pulses1.passive];
P2 = [pulses2.active, pulses2.passive];
noPulses = size(P1,2);

%%
[crosscorrelation1, MaxCorr1, BestLag1] = crosscorr(P1, P1, 1, length(P1), 'coeff');
[crosscorrelation2, MaxCorr2, BestLag2] = crosscorr(P2, P2, 1, length(P2), 'coeff');

% Mean_MaxCorr = (MaxCorr1 + MaxCorr2)/2;
mm(:,:,1) = MaxCorr1;
mm(:,:,2) = MaxCorr2;
Mean_MaxCorr = mean(mm,3);
Std_MaxCorr = std(mm,0,3);
%%
matrix_plot(Mean_MaxCorr, noPulses, 'Cross Correlation: Raw Pulses', 'Mean Max Corr', 'Pulse #', 'Pulse #')
colormap gray
axis xy