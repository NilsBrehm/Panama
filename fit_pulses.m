function y_fit = fit_pulses(pulses, windowstart, windowend, degree)
active = pulses(windowstart:windowend,:);
noPulses=size(active, 2);
tt = [0:1:length(active)]';
tt(end) = [];
x1 = 0:0.01:length(active);
p = zeros(degree+1, noPulses);
y_fit = zeros(length(x1),noPulses);
for i = 1:noPulses
    p(:,i) = polyfit(tt,active(:,i),degree);
    y_fit(:,i) = polyval(p(:,i),x1);
end
end