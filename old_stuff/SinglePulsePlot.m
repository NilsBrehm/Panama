time = 0:1/samplingrate:length(pulses.active(:,end))/samplingrate;
time = time*1000;
%%
subplot(2,1,1)
plot(time(1:end-1), pulses.active(:,end), 'k', 'LineWidth', 3)
xlabel('Zeit [ms]')
ylabel('Amplitude')
ylim([-.8, .8])
yticks(-.8:.4:.8)
xlim([0, .2])
xticks(0:.05:.2)
set(gca, 'xlabel', [], 'xticklabel', [])
box off

subplot(2,1,2)
plot(time(1:end-1), pulses.passive(:,1), 'k', 'LineWidth', 3)
xlabel('Zeit [ms]')
ylabel('Amplitude')
ylim([-.8, .8])
yticks(-.8:.4:.8)
xlim([0, .2])
xticks(0:.05:.2)
box off