locs = locs_ps;
%%
clc
for i = 1:length(locs)
    pulse_full = data(locs(i)-10:locs(i)+10);
    th = mad(pulse_full, 2);
    [locsA, pksA] = peakseek(pulse_full, 10, th);
    [locsP, pksP] = peakseek(-pulse_full, 10, th);
    
    if locsA(1) < locsP(1)
        tlt = 'Active';
    else
        tlt = 'Passive';
    end
    
    % Plot
    subplot(2, 1, 1)
    plot(pulse_full, 'k')
    hold on
    plot(locsA(1), pulse_full(locsA(1)), 'ro')
    hold on
    plot([1, length(pulse_full)], [th, th], 'b--')
    hold on
    plot([1, length(pulse_full)], [-th, -th], 'b--')
    title(tlt)
    hold off
    subplot(2, 1, 2)
    plot(pulse_full, 'k')
    hold on
    plot(locsP(1), pulse_full(locsP(1)), 'ro')
    hold on
    plot([1, length(pulse_full)], [th, th], 'b--')
    hold on
    plot([1, length(pulse_full)], [-th, -th], 'b--')
    hold off
    waitforbuttonpress;
end
%%
pulse = pulse_full(1:50);
dt = 1/(480*1000);
t = 0:dt:length(pulse)*dt;
t(end) = [];

%% Find max freq of pulse
[ppx, ff] = periodogram(pulse,[],[],1/dt);
maxf = ff(ppx == max(ppx));

%% Compute sinus templates
s1 = max(pulse) * sin(maxf*2*pi*t);
s2 = -s1;

%% Plot
plot(t, pulse, 'k')
hold on
plot(t, s1, 'r')
hold on
plot(t, s2, 'b')


%% Correlate sinus templates with pulse
r1 = corr(pulse, s1');
r2 = corr(pulse, s2');

if r1 > 0
    disp('active')
else
    disp('passive')
end