function [r1, r2] = avsp_sincorr(pulse, dt)

t = 0:dt:length(pulse)*dt;
t(end) = [];

% Find max freq of pulse
[ppx, ff] = periodogram(pulse,[],[],1/dt);
maxf = ff(ppx == max(ppx));

% Compute sinus templates
s1 = max(pulse) * sin(maxf*2*pi*t);
s2 = -s1;

% Correlate sinus templates with pulse
r1 = corr(pulse, s1');
r2 = corr(pulse, s2');

end