function output = bandpassfilter_data(data, fc_low, fc_high, order, fs)
% This function filters sound recordings using a Butterworth high and low
% pass filter.
% 
% Copyright Nils Brehm 2018

% High Pass Filter
[b,a] = butter(order,fc_low/(fs/2),'high'); % Butterworth filter of order x
output = filter(b, a, data); % Will be the filtered signal

% Low Pass Filter
[b,a] = butter(order,fc_high/(fs/2),'low'); % Butterworth filter of order x
output = filter(b, a, output); % Will be the filtered signal

end