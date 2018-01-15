%% Sharpness of Cross Correlation Function
Sharpness = zeros(1, noPulses-1);
i = 1;
k = noPulses;
for pp = 1:noPulses-1
    %sharpness(pp) = (MaxCorr_raw(i,k)+MaxCorr_raw(i,k-1)+MaxCorr_raw(i+1,k)+MaxCorr_raw(i+1,k-1))/4;
    Sharpness(pp) = std([MaxCorr_raw(i,k) MaxCorr_raw(i,k-1) MaxCorr_raw(i+1,k) MaxCorr_raw(i+1,k-1)]);
    i = i+1;
    k = k-1;
end



%% Sharpness for AvsA and PvsP
Sharpness = zeros(1, noPulses-1);
for i = 1:noPulses-1
    Sharpness(i) = std([MaxCorr_raw(i,i) MaxCorr_raw(i,i+1) MaxCorr_raw(i+1,i) MaxCorr_raw(i+1,i+1)]);
end

%% Plot Sharpness
plot(Sharpness, '-ok')
xlabel('Zone')
ylabel('Sharpness ( of CCF) [STD n = 4]')
xticks(1:noPulses-1)
xlim([0 noPulses])
box off

%%
%% Plot Sharpness
plot(mean([SharpnessAA; SharpnessPP],1), '--oy', 'LineWidth', 3)
hold on
plot((1.2*SharpnessAA+SharpnessPP*.6)/2, '--og', 'LineWidth', 3)
hold on
%plot(abs(SharpnessAA-SharpnessPP), '-oy')
%hold on
plot(SharpnessAP,'-ok', 'linewidth', 2)
hold on
plot(SharpnessPP, '-ob', 'LineWidth', 2)
hold on
plot(SharpnessAA, '-or', 'LineWidth', 3)
xlabel('Zone')
ylabel('Sharpness ( of CCF) [STD n = 4]')
xticks(1:noPulses-1)
xlim([0 noPulses])
box off
legend('Mean(AvsA and PvsP)', 'Weighted Mean', 'AvsP', 'PvsP', 'AvsA')