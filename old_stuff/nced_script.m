%% Normalised cumulative energy difference
% Nhamoinesu Mtetwa and Leslie S. Smith - Smoothing and thresholding in
% neuronal spike detection (2006)
x = data;
energy = sum(abs(x).^2);
nce = cumsum(x.^2)/energy;
nced = diff(nce);

%% NonLinear Energy Operator
% http://gaidi.ca/weblog/extracting-spikes-from-neural-electrophysiology-in-matlab
neo = zeros(length(x),1);
for n = 2:1:length(x)-1
    neo(n) = x(n).^2 - x(n+1)*x(n-1);
end

%% Plot
plot(x*max(nced), 'k')
hold on
plot(nced, 'r')
hold on
plot(neo*max(nced), 'b')
legend('data', 'nced', 'neo')

%% Second Derivative/Difference
secd = diff(x, 2);
secd2 = zeros(length(x)-1, 1);
for i = 2:1:length(x)-1
    secd2(i) = x(i+1) - 2*x(i) + x(i-1);
end
secd2(1) = [];
plot(x*max(secd), 'k')
hold on
plot(secd, 'r')
hold on
plot(secd2, 'b--')