function combined_matrix_plot(MaxCorr_AP, threshold, showvalues)
% This function plots a matrix plot with the diagonal highlighted (red line
% with diamonds). Max. Cross Correlation values are marked (blue circles) 
% and a range defined by 'threshold' is indicated (x--x). This function
% only works for equal number of active and passive pulses.
% 
% Copyright Nils Brehm 2018

% Calculation
% threshold = 0.85;
noPulses = length(MaxCorr_AP);
cmaxA = zeros(1,noPulses);
cmaxP = cmaxA;
ca = cell(1,noPulses);
cp = cell(1,noPulses);
for i = 1:noPulses
    cmaxA(i) = find(MaxCorr_AP(i,:) == max(MaxCorr_AP(i,:)));
    cmaxP(i) = max(MaxCorr_AP(i,:));
    ca{i} = find(MaxCorr_AP(i,:) >= threshold);
    cp{i} = find(MaxCorr_AP(:,i) >= threshold);
end

% Matrix Plot
diag = 1:noPulses;
diagAP = noPulses:-1:1;
matrix_plot(MaxCorr_AP, noPulses, noPulses,...
    'Best Cross Correlation [r]','Passive Pulse Number', 'Active Pulse Number',...
    [0, 1], showvalues); axis equal; xlim([0.5 noPulses+0.5]); box off; axis xy;
hold on
for k = 1:noPulses
    plot(ca{k},ones(size(ca{k},2))*k, '--xk', 'MarkerSize',12, 'LineWidth',2)
    %hold on
    %plot(noPulses-k+1,k,'rd', 'MarkerSize',12, 'LineWidth',2)
    hold on
    plot(cmaxA(k),k, 'bo', 'MarkerSize',12, 'LineWidth',2)
end
hold on
plot(diag, diagAP, '-dr', 'MarkerSize',10, 'LineWidth',1.5)

end

