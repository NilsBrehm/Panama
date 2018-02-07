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

%% Get Data
call_nr = 5;
% Carales
animal = '/media/brehm/Data/Panama/DataForPaper/Castur/PK1285/Pk12850014/';
carales = cell(1,call_nr);
for k = 1:call_nr
load([animal, 'call_nr_', num2str(k), '/call_nr_', num2str(k), '_samples.mat'])
carales{k} = [samples.active, samples.passive];
end

% Melese
animal = '/media/brehm/Data/Panama/DataForPaper/Melese_incertus/PK1297/Pk12970002/';
melese = cell(1,call_nr);
for k = 1:call_nr
load([animal, 'call_nr_', num2str(k), '/call_nr_', num2str(k), '_samples.mat'])
melese{k} = [samples.active, samples.passive];
end

%%
samplingrate = 480 * 1000;
train1 = carales{2}/samplingrate;
train2 = carales{5}/samplingrate;

%% Compute Van Rossum Distance
tic
tau = 10; % in ms
taus = [0.1:0.1:100];
dt_factor = 1000;
D = zeros(100, 3);
% Use vrd function
for k = 1:length(taus)
[D(k,1), D(k,2), D(k,3)] = vrd(train1, train2, taus(k), dt_factor, false);
end
toc

% Compute expected values for tau limits
sc = ((length(train1)-length(train2))^2)/2;
diff_sc = abs(length(train1)-length(train2));
diff_sc_estimate = sqrt(2*sc);
nce = (length(train1)+length(train2))/2;

%% Plot tau vs Distance
plot(taus, D(:,1), 'k', 'LineWidth', 3)
xlabel('Tau [ms]', 'FontSize', 14)
ylabel('Van Rossum Distance', 'FontSize', 14)
hold on
plot([taus(1), taus(end)], [sc, sc], 'r--', 'LineWidth', 2)
hold on
plot([taus(1), taus(end)], [nce, nce], 'r--', 'LineWidth', 2)
box off
text(10, nce-1.5, 'Number of NonCoincident Events: \(\lim\limits_{\tau \to 0}D(\tau)=\frac{(M+N)}{2}\)','Interpreter','latex')
text(10, sc-1.5, 'Difference in Event Counts: \(\lim\limits_{\tau \to \infty}D(\tau)=\frac{(M-N)^2}{2}\)','Interpreter','latex')
set(gca,'linewidth', 1.5)

%% Display values
clc
disp(['VanRossum Distance: ', num2str(d), ' (tau =  ', num2str(tau), ' ms)'])
disp(['Count Estimate for Train 1: ', num2str(c_f), ' (true: ', num2str(length(train1)), ')'])
disp(['Count Estimate for Train 2: ', num2str(c_g), ' (true: ', num2str(length(train2)), ')'])
disp(['Difference in Event Counts (large taus): ', num2str(sc)])
disp(['Absolute Difference in Event Counts (large taus): ', num2str(diff_sc_estimate), ' (true: ', num2str(diff_sc), ')'])
disp(['Number of NonCoincident Events : ', num2str(nce)])

%% Artificial Moth Call
clc
dt_factor = 4800;
tau = 1; % in ms
freq = [30, 70, ...
        30, 70, ...
        35, 65, ...
        40, 50,...
        55]; % in kHz
pulse_times1 = [0.01, 0.01, ...
                0.02, 0.02, ...
                0.03, 0.03, ...
                0.04, 0.04, ...
                0.05]; % in seconds

amp = [.8, .2, ...
       .8, .2, ...
       .8, .2, ...
       .8, .2, ...
       1];
f = amc(pulse_times1, tau, freq, amp, dt_factor, true);
