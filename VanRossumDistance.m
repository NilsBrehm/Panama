% For tau -> inf: d measures difference in spike number
% For tau -> 0  : d measures number of non-coincident spikes
% One Spike deleted/inserted: d = 0.5;
% One Spike shifted: d = 1
% 
%% Create Trains and set parameters
clc
train1 = [0.1, 0.2, 0.3, 0.5, 0.55];
train2 = train1;
train2(2) = [];

tau = 10; % in ms
dt_factor = 100;
t = 0:dt:1;

%% Use vrd function
[d, c_f, c_g] = vrd(train1, train2, tau, dt_factor);
clc
disp(['VanRossum Distance: ', num2str(d)])
disp(['Count Train 1: ', num2str(c_f)])
disp(['Count Train 2: ', num2str(c_g)])
