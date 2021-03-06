function plot_stuff(time, active, passive)
% This function plots a cut out pulses
% 
% Copyright Nils Brehm 2018

subplot(1,2,1)
plot(time, active)
title('Active Pulses')
ylim([min(min(active)), max(max(active))])
ylabel('Amplitude')
xlabel('time [ms]')

subplot(1,2,2)
plot(time, passive)
title('Passive Pulses')
ylim([min(min(passive)), max(max(passive))])
xlabel('time [ms]')
% 
% subplot(2,2,3)
% plot(time(windowstart:windowend), active(windowstart:windowend,:),'-o')
% title('Active Pulses: Analysis Window')
% ylim([min(min(active)), max(max(active))])
% xlim([min(time(windowstart:windowend))-0.01, max(time(windowstart:windowend))+0.01])
% xlabel('time [ms]')
% ylabel('Amplitude')
% 
% subplot(2,2,4)
% plot(time(windowstart:windowend), passive(windowstart:windowend,:),'-o')
% title('Passive Pulses: Analysis Window')
% ylim([min(min(passive)), max(max(passive))])
% xlim([min(time(windowstart:windowend))-0.01, max(time(windowstart:windowend))+0.01])
% xlabel('time [ms]')
end
