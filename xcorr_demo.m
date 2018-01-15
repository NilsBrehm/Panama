% Constants:
samplingrate = 480 * 1000; % sampling rate in Hz
pulse_length = 0.4;
tau = 0.1;
t = 0:1/samplingrate:pulse_length/1000; % pulse length = 0.4 ms
amp = 1;
dumping = tau/1000; % tau in seconds (0.1 ms)
xshift = 0.2; % no shift
f = 20*1000*2*pi;
q1 = artifical_moth(t,amp,f, dumping, 0);
q2 = artifical_moth(t,amp,f, dumping, 0);

%%
[r, lags] = xcorr(q1,q2, 'coeff');

%%
subplot(2,1,1)
plot(t*1000,q1, 'k', 'LineWidth', 2)
hold on
plot((t+.0001)*1000,q2, '--r', 'LineWidth', 2)
hold on
plot((t-.0004)*1000,q2, '--r', 'LineWidth', 2)
hold off
xlim([-.5,.5])
xticks(-.5:.1:.5)
xlabel('Zeit [ms]')
ylabel('Amplitude')

subplot(2,1,2)
plot(lags/samplingrate*1000, r, 'k', 'LineWidth', 2)
xlabel('Lags [ms]')
ylabel('Correlation [r]')
xlim([-.5,.5])
xticks(-.5:.1:.5)