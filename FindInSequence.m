plot(MaxCorr_AA(1,:))

%%
dummyA = MaxCorr_AA(10,:);
dummyP = MaxCorr_AP(10,:);
dummyA1 = MaxCorr_AA(2,:);
dummyP1 = MaxCorr_AP(2,:);
%%
[~, marksA] = findpeaks(dummyA, 'MinPeakDistance',3, 'MinPeakHeight', 0.85);
[~, marksP] = findpeaks(dummyP, 'MinPeakDistance',3, 'MinPeakHeight', 0.85);

%%
k = 0;
r = zeros(length(data),1);
for i = samples.active
    k = k+1;
    r(i) = dummyA(k);
end

%% Plot Marked Active and Passive Pulses
time = 1:length(data);
plot(data, 'k')
hold on
% marksP = [4, 25, 42, 62, 81, 96, 108];
% marksA = [1, 5, 27, 44, 63, 81, 96, 107];
for i = marksP
    plot(time(samples.passive(i):samples.passive(i)+100), data(samples.passive(i):samples.passive(i)+100), 'b')
end
for i = marksA
    plot(time(samples.active(i):samples.active(i)+100), data(samples.active(i):samples.active(i)+100), 'r')
    
end

%%
for i = 1:length(samples.active)
    plot([samples.active(i), samples.active(i)], [0,0.5], 'k')
    hold on
end

%%
u = 0;
for k = samples.active
    u = u+1;
    plot([k, k], [0, dummyA(u)], 'ro')
    hold on
    plot([k, k], [0, dummyA1(u)], 'rx')
    hold on
end
u = 0;
for k = samples.passive
    u = u+1;
    plot([k, k], [0, dummyP(u)], 'bo')
    hold on
    plot([k, k], [0, dummyP1(u)], 'bx')
    hold on
end
plot([1, length(data)], [0.95, 0.95], 'k')

%%
plot(dummyA, 'r-o')
hold on
plot(dummyA1, 'r-x')
hold on
plot(dummyP, 'b-o')
hold on
plot(dummyP1, 'b-x')