%% Pulse Train Distance
% Based on Spike Train Distance method. 
% An exp() function with a specific damping factor (tau) is added to every
% single pulse starting time. Than the Sum of the squarred difference of
% both pulse trains (calls) is calculated. This distance is a measure for
% the (dis)smimilarity between two pulse trains (calls).
% 
% Copyright Nils Brehm 2018

distance = sqrt((call_1 - call_2).^2);

%%
subplot(3,1,1)
plot(call_1, 'k')
subplot(3,1,2)
plot(call_2, 'k')
subplot(3,1,3)
plot(distance, 'r')
%%
calldiff = sum(sqrt((call_1 - call_2).^2));
disp(['Call Distance: ', num2str(calldiff)])

%%
p_times2 = [samples.active, samples.passive];

%%
