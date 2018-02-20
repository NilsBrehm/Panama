% Artificial Moth Calls
% Compute artifical moth calls by using a damped sinus as a model for
% single pulses. The call is created by transforming the discrete time
% points of pulses into a continues heaviside step function. This function
% is then convolved with a damped sinus.
%
% Input:
% - pulse_times: vector with time points (in seconds)
% - tau: damping factor of damped sinus (in milliseconds)
% - freq: vector containing the respective frequencies (in kHz)
% - amp: vector containing the respective amplitudes
% - dt_factor: time step = tau/dt_factor
% - plot_it: if true plot call
% 
% Output:
% - f: pulse train (call)
% 
% To create poly-tonal pulses give pulse position several times and
% change the corresponding frequencies and amplitudes.
% 
% Example:
% freq = [3, 6, 5, 4]
% pulse_times = [0.01, 0.01, 0.01, 0.04]
% amp = [.5, .5, .3, 1];
% This will create two pulses. The First Pulse will have three different
% frequency compontents weighted with the correpsonding amplitude.
% 
% Copyright Nils Brehm 2018
%
function f = amc(pulse_times1, tau, freq, amp, dt_factor, plot_it)
% Set parameters
time_limit = max(pulse_times1);
tau = tau/1000; % now tau is in seconds
dt = tau/dt_factor;
t = 0:dt:time_limit+10*tau;
xshift = 0;
freq = freq*1000*2*pi;

% Add dammped sinus
H = zeros(length(pulse_times1), length(t));
for i = 1:length(pulse_times1)
    H(i,:) = heaviside(t-pulse_times1(i)).* (exp(-(t-pulse_times1(i))/tau).*amp(i).*sin(freq(i)*((t-pulse_times1(i))+xshift)));
end
f = sum(H);

% Plot
if plot_it
    figure()
    plot(t, f, 'k')
end

end