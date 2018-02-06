function d = PulseTrainDistance(train1, train2, tau, dt)
%% Pulse Train Distance
% Based on Spike Train Distance method. 
% An exp() function with a specific damping factor (tau) is added to every
% single pulse starting time. Than the Sum of the squarred difference of
% both pulse trains (calls) is calculated. This distance is a measure for
% the (dis)smimilarity between two pulse trains (calls).
% 
% Copyright Nils Brehm 2018

% %% Difference between audio recording
% distance = sqrt((call_1 - call_2).^2);
% 
% %% Plot
% subplot(3,1,1)
% plot(call_1, 'k')
% subplot(3,1,2)
% plot(call_2, 'k')
% subplot(3,1,3)
% plot(distance, 'r')
% 
% calldiff = sum(sqrt((call_1 - call_2).^2));
% disp(['Call Distance: ', num2str(calldiff)])

%% Pulse Train Distance --------------------------------------------------
% 
%% Add exponential tails
% Find longest train
tau = tau/1000; % in seconds
longest = max([max(train1), max(train2)]);
t = 0:dt:(longest*dt)+5*tau;


% TRAIN 1
e_tail1 = zeros(1,length(t));
for i = 1:length(train1)
   e_pulse = zeros(1,length(t));
   idx = round(train1(i));
   et = t(idx:end);
   et = et-et(1);
   e_pulse(idx:end) = exp(-et/tau);
   e_tail1 = e_tail1 + e_pulse;
end
% TRAIN 2
e_tail2 = zeros(1,length(t));
for i = 1:length(train2)
   e_pulse = zeros(1,length(t));
   idx = round(train2(i));
   et = t(idx:end);
   et = et-et(1);
   e_pulse(idx:end) = exp(-et/tau);
   e_tail2 = e_tail2 + e_pulse;
end

% Plot
subplot(2, 1, 1)
plot(t, e_tail1, 'k')
subplot(2, 1, 2)
plot(t, e_tail2, 'k')

% Compute Pulse Train Distance
% tau must be in samples!
% Remove or Insert one Pulse: D = 0.5
% Shift one Pulse in time: D = 1

% d = (1/(tau*fs)) * sum((e_tail1-e_tail2).^2);

% d = sum(e_tail1) * (dt/tau);
d = (dt/tau) * sum((e_tail1-e_tail2).^2);
end
