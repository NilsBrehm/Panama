p = MaxCorr_AP./sum(sum(MaxCorr_AP)); % overall sum = 1
nhood = strel('square', 9);
en = entropyfilt(p,  nhood.Neighborhood);

%%
subplot(1,2,1)
imagesc(p)
% axis equal
axis xy
colorbar
xticks(1:1:noPulses)
yticks(1:1:noPulses)
ylabel('Active Pulses')
xlabel('Passive Pulses')
title('Normalized XCorr')

subplot(1,2,2)
imagesc(en)
% axis equal
axis xy
colorbar
xticks(1:1:noPulses)
yticks(1:1:noPulses)
ylabel('Active Pulses')
xlabel('Passive Pulses')
title('Entropy')

%% Calculation
threshold = 0.85;
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

%% Max Plot
for k = 1:noPulses
plot(k,cmaxA(k), '--ok')
hold on
plot(k,noPulses-k+1,'rx')
end
xlabel('Pulse Number')
ylabel('Pulse with equal sound characteristics')
xticks(1:noPulses)
yticks(1:noPulses)
grid on

%% AvsA or PvsP
for k = 1:noPulses
plot(ones(size(ca{k},2))*k,ca{k}, '--ok')
hold on
plot(k,k,'ro')
end
xlabel('Pulse Number')
ylabel('Pulse with equal sound characteristics')
xticks(1:noPulses)
yticks(1:noPulses)
grid on

%% AvsP
subplot(2,1,1)
for k = 1:noPulses
plot(ones(size(ca{k},2))*k,ca{k}, '--ok')
hold on
plot(k,noPulses-k+1,'rx')
hold on
plot(k,cmaxA(k), 'bx')
end
xlabel('Active Pulse Number')
ylabel('Passive Pulse with equal sound characteristics')
xticks(1:noPulses)
yticks(1:noPulses)
grid on
subplot(2,1,2)
for k = 1:noPulses
plot(ones(size(cp{k}',2))*k,cp{k}', '--ok')
hold on
plot(k,noPulses-k+1,'rx')
hold on
plot(k,cmaxP(k), 'bx')
end
xlabel('Passive Pulse Number')
ylabel('Active Pulse with equal sound characteristics')
xticks(1:noPulses)
yticks(1:noPulses)
grid on

%% Combined Matrix Plot
diag = 1:noPulses;
diagAP = noPulses:-1:1;
matrix_plot(MaxCorr_AP, noPulses, noPulses,...
    'Best Cross Correlation [r]','Passive Pulse Number', 'Active Pulse Number',...
    [0, 1]); axis equal; xlim([0.5 noPulses+0.5]); box off; axis xy;
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

%% ---------------------------------------
%% Calculation
threshold = 0.75;
cmaxA = zeros(1,noPulses);
cmaxP = cmaxA;
ca = cell(1,noPulses);
cp = cell(1,noPulses);
for i = 1:noPulses
    
    cmaxA(i) = find(MaxCorrAA(i,:) == max(MaxCorrAA(i,:)));
    cmaxP(i) = find(MaxCorrPP(i,:) == max(MaxCorrPP(i,:)));
    ca{i} = find(MaxCorrAA(i,:) >= threshold);
    cp{i} = find(MaxCorrPP(:,i) >= threshold);
    cmaxAP(i) = find(MaxCorrAP(i,:) == max(MaxCorrAP(i,:)));
    cap{i} = find(MaxCorrAA(i,:) >= threshold);
end
%% Combined Matrix Plot
diag = 1:noPulses;
diagAP = noPulses:-1:1;

for k = 1:noPulses
plot(cap{k},ones(size(cap{k},2))*k, '--dk', 'MarkerSize',12, 'LineWidth',2)
%hold on
%plot(noPulses-k+1,k,'rd', 'MarkerSize',12, 'LineWidth',2)
hold on
plot(cmaxAP(k),k, 'ko', 'MarkerSize',12, 'LineWidth',2)
end
hold on
for k = 1:noPulses
plot(ca{k},ones(size(ca{k},2))*k, '--xr', 'MarkerSize',12, 'LineWidth',2)
%hold on
%plot(noPulses-k+1,k,'rd', 'MarkerSize',12, 'LineWidth',2)
hold on
plot(cmaxA(k),k, 'ro', 'MarkerSize',12, 'LineWidth',2)
end
hold on
for k = 1:noPulses
plot(cp{k},ones(size(cp{k},2))*k, '--xb', 'MarkerSize',12, 'LineWidth',2)
%hold on
%plot(noPulses-k+1,k,'rd', 'MarkerSize',12, 'LineWidth',2)
hold on
plot(cmaxP(k),k, 'bo', 'MarkerSize',12, 'LineWidth',2)
end

