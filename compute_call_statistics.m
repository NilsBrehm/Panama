function call_stats = compute_call_statistics(data, samples, samplingrate, singlepulselength, dspl)
% Computes descripitve statistics of moths calls.
%
% - Pulse Duration (active and passive)
% - Inter Pulse Interval (IPI) (active and passive)
% - Inter Train Interval (ITI) (pause between active and passive train)
% - Pulse Train Duration (active and passive)
% - Call Duration
% - Frequency Components
%
% Input:
% - data: Moth Recording
% - samples: Struct Array of Pulse Starting Points (in samples)
%            samples = samples.active and samples.passive
% - samplingrate:  Sampling Rate of Recording in Hz
% - dspl: If true than single pulse length will be computed, otherwise
%           single pulse length of input is used.
%
% Output: call_stats:
% 01: single pulse length
% 02: active single pulse length
% 03: passive single pulse length
% 04: Inter Pulse Intervals
% 05: Active Inter Pulse Intervals
% 06: Passive Inter Pulse Intervals
% 07: Inter Train Intervals (method 1)
% 08: Inter Train Intervals (method 2)
% 09: Call Duration
% 10: Active Train Duration
% 11: Passive Train Duration
%
% Copyright Nils Brehm 2018

% Detect Single Pulse Length
Peak = [samples.active, samples.passive];
limit =  quantile(data, .95);

if dspl
    singlepulselength = zeros(1, length(Peak));
    j = 1;
    for i = Peak
        k = 0;
        while max(data(i+k:i+k+100)) >= limit
            k = k+1;
            % Make sure that the pulse does not exceeds the next one
            if j < length(Peak) && (i+k) >= Peak(j+1)
                break;
            end
        end
        singlepulselength(j) = k;
        j = j+1;
    end
end
% Detect Call Statistics
% Single Pulse Length (active and passive)
spl = singlepulselength / samplingrate * 1000;
spl_A = spl(1:length(samples.active));
spl_P = spl(length(samples.active)+1:end);
IPIs = (diff(Peak)/samplingrate)*1000;
A_IPIs = (diff(samples.active)/samplingrate)*1000;
P_IPIs = (diff(samples.passive)/samplingrate)*1000;
ITI2 = (samples.passive(1)-samples.active(end))/samplingrate*1000; % only if A and P are completley separated
ITI = max(IPIs);  % Inter Train Interval: Interval between Active and Passive Train
pulse_train_duration = (max([samples.passive, samples.active]) - min([samples.passive, samples.active]))/samplingrate*1000;
A_dur = (max(samples.active) - min(samples.active)) / samplingrate * 1000;
P_dur = (max(samples.passive) - min(samples.passive)) / samplingrate * 1000;

%               1   2       3      4      5       6     7     8
call_stats = {spl, spl_A, spl_P, IPIs, A_IPIs, P_IPIs, ITI, ITI2,...
    pulse_train_duration, A_dur, P_dur};
%           9               10     11

end