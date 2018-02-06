% For tau -> inf: d measures difference in spike number: 
%   d = (M-N)^2 / 2 which yields: M-N = sqrt(2*d)
% For tau -> 0  : d measures number of non-coincident spikes
%   d = (M+N)/2
% One Spike deleted/inserted: d = 0.5;
% One Spike shifted: d = 1
% 
%% Create Trains and set parameters
clc
train1 = [0.1, 0.2, 0.3, 0.5, 0.55];
train2 = train1;
train2(2) = [];
%% Compute Van Rossum Distance
tic
tau = 10000; % in ms
dt_factor = 1000;

sc = ((length(train1)-length(train2))^2)/2;
nce = (length(train1)+length(train2))/2;

% Use vrd function
[d, c_f, c_g] = vrd(train1, train2, tau, dt_factor, false);
clc
disp(['VanRossum Distance: ', num2str(d), ' (tau =  ', num2str(tau), ' ms)'])
disp(['Count Estimate for Train 1: ', num2str(c_f), ' (true: ', num2str(length(train1)), ')'])
disp(['Count Estimate for Train 2: ', num2str(c_g), ' (true: ', num2str(length(train2)), ')'])
disp(['Difference in Event Counts (large taus): ', num2str(sc)])
disp(['Number of NonCoincident Events (small taus): ', num2str(nce)])
toc