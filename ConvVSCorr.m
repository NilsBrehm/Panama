% Convolution vs. Cross Correlation
dt = 0.001;
t = -1:dt:1;
%f = sin(20*t);
f = rectpuls(t);
%g = cos(t);
%g = triangularPulse(t);
%g = sawtooth(t);
g = exp(-t);

%f = g;
[r, lags] = xcorr(f,g);
c = conv(f,g);

lags = lags*dt;

%% Plot
figure()
subplot(3,1,1)
plot(t, f, 'LineWidth', 1.5)
hold on
plot(-t, g, 'r')
hold on
plot(t-1, g, 'k--')
ylim([0, 1])
title('Function')
legend('f(tau)', 'g(t-tau)', 'g(t+tau)')
xlabel('tau')

subplot(3,1,2)
plot(lags, r, 'LineWidth', 1.5)
ylim([0, max(r)])
xlim([lags(1), lags(end)])
title('Cross Correlation')
xlabel('t')

subplot(3,1,3)
plot(lags, c, 'LineWidth', 1.5)
ylim([0, max(c)])
xlim([lags(1), lags(end)])
title('Convolution')
xlabel('t')