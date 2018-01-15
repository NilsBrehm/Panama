

%% Actives
A1 = pulses1.active;
A2 = pulses2.active;
A1_sz = size(A1);
A2_sz = size(A2);
dA = abs(A1_sz(2)-A2_sz(2));

if A1_sz(2) < A2_sz(2)
    A1(end:end+dA) = 0;
elseif A1_sz(2) > A2_sz(2)
    A2(:,end:end+dA) = 0;
end

%% Passives
P1 = pulses1.passive;
P2 = pulses2.passive;
P1_sz = size(P1);
P2_sz = size(P2);
dP = abs(P1_sz(2)-P2_sz(2));

if P1_sz(2) < P2_sz(2)
    P1(end:end+dP) = 0;
elseif P1_sz(2) > P2_sz(2)
    P2(:,end:end+dP) = 0;
end
%% Choose analysis window
windowstart = 1;
windowend = length(A1);

[crosscorrelationA, MaxCorrA, BestLagA] = crosscorr(A1, A2, windowstart, windowend, 'coeff');
[crosscorrelationP, MaxCorrP, BestLagP] = crosscorr(P1, P2, windowstart, windowend, 'coeff');
noPulses = size(A1,2);

%%
figure()
plot(A1(:,2))
hold on
plot(A2(:,2))
%% Plot Actives
pos_fig = [0 0 1080 1080];
fig = figure();
set(fig,'Position',pos_fig, 'Color', 'white')
matrix_plot(MaxCorrA, noPulses, 'Cross Correlation: Raw Pulses', 'Max. Correlation', 'Active Call 2', 'Active Call 1', [0 1]);

export_fig('/home/brehm/Desktop/Panama/data/Carales/Individual01_Actives.png','-m2')
close
%% Plot Passives
fig = figure();
set(fig,'Position',pos_fig, 'Color', 'white')
matrix_plot(MaxCorrP, noPulses, 'Cross Correlation: Raw Pulses', 'Max. Correlation', 'Passive Call 2', 'Passive Call 1', [0 1]);

export_fig('/home/brehm/Desktop/Panama/data/Carales/Individual01_Passives.png','-m2')
close