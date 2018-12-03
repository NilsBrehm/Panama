% Computes Van Rossum Distance for time events.
% For tau -> inf: d measures difference in spike number
% For tau -> 0  : d measures number of non-coincident spikes
% One Spike deleted/inserted: d = 0.5;
% One Spike shifted: d = 1
%
% Input:
% - train1 and train2 are vectors containing event times (in seconds)
% - tau (time constant) in milliseconds
% - dt_factor: dt (time step) equals tau/dt_factor
%
% Output:
% - d: Van Rossum Distance
%
% Copyright Nils Brehm 2018
%
function [d, c_f, c_g] = vrd(train1, train2, tau, dt_factor, plot_it)
% Set parameters
time_limit = max([max(train1), max(train2)]);
tau = tau/1000; % now tau is in seconds
dt = tau/dt_factor;
t = 0:dt:time_limit+5*tau;

% Add exponential
% Train 1
H = zeros(length(train1), length(t));
for i = 1:length(train1)
    H(i,:) = heaviside(t-train1(i)).*exp(-(t-train1(i))/tau);
end
f = sum(H);

% Train 2
H = zeros(length(train2), length(t));
for i = 1:length(train2)
    H(i,:) = heaviside(t-train2(i)).*exp(-(t-train2(i))/tau);
end
g = sum(H);

% Train Distance
d = (dt/tau) * sum((f-g).^2);
c_f = (dt/tau) * sum(f);
c_g = (dt/tau) * sum(g);

% Plot
if plot_it
    figure()
    subplot(2, 1, 1)
    plot(f, 'k')
    subplot(2, 1, 2)
    plot(g, 'k')
end

end