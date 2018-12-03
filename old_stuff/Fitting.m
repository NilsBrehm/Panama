% Fitting
samplingrate = 480000;
rawdata = pulses.active(windowstart:end,5);
rawdata1 = rawdata-rawdata(1);
t = 0:1/samplingrate:length(rawdata1)/samplingrate;
t(end) = [];
t_samples = 0:length(rawdata1);
t_samples(end) = [];
amp = 0.5;
f = .4;
dumping = 50;
xshift = -2;

%FIT = zeros(length(t),3);

FIT = artifical_moth(t_samples, amp, f, dumping, xshift)';


plot(t, rawdata1, '-ok', 'LineWidth', 2)
hold on
plot(t, FIT+0.1, 'red', 'LineWidth', 2)

%% Poly Fit
tt = [0:1:length(rawdata)]';
tt(end) = [];

p = polyfit(tt,rawdata,12);
x1 = 0:0.01:length(rawdata);
y1 = polyval(p,x1);

figure()
plot(tt, rawdata, 'o')
hold on
plot(x1, y1)
