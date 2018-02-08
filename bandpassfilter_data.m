function output = bandpassfilter_data(data, fc_low, fc_high, order, fs, high_pass, low_pass)
% This function filters sound recordings using a Butterworth high and low
% pass filter.
%
% Copyright Nils Brehm 2018

% High Pass Filter
if high_pass
    [b,a] = butter(order,fc_low/(fs/2),'high'); % Butterworth filter of order x
    output = filter(b, a, data); % Will be the filtered signal
else
    output = data;
end

% Low Pass Filter
if low_pass
    [b,a] = butter(order,fc_high/(fs/2),'low'); % Butterworth filter of order x
    output = filter(b, a, output); % Will be the filtered signal
end

end