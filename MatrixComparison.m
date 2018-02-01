m = [];
%% Open data
path_linux = '/media/brehm/Data/Panama/DataForPaper/Castur/PK1285/sorted/';
path_windows = 'D:\Masterarbeit\PanamaProject\DataForPaper\';

[file,path] = uigetfile([path_linux, '*.mat'],'select a wav file');
% open(fullfile(path,file))
%%
m = [m, load([path, file], 'MaxCorr_AP')];

%% MSE: Matices must have same size
err1 = immse(m(1).MaxCorr_AP,m(2).MaxCorr_AP);
err2 = immse(m(1).MaxCorr_AP, m(3).MaxCorr_AP);
err3 = immse(m(2).MaxCorr_AP, m(3).MaxCorr_AP);
% = mean(mean((m1-m2).^2))

%% 2-norm
n1= norm(m(1).MaxCorr_AP);
n2= norm(m(2).MaxCorr_AP);
n3= norm(m(3).MaxCorr_AP);
n4= norm(m(4).MaxCorr_AP);

%% Frobenius norm
nf1 = norm(m(1).MaxCorr_AP,'fro');
nf2 = norm(m(2).MaxCorr_AP,'fro');
nf3 = norm(m(3).MaxCorr_AP,'fro');
nf4 = norm(m(4).MaxCorr_AP,'fro');

%%
figname = 'Melese';
MM = fliplr(m(3).MaxCorr_AP);
noPulses = length(MM)-1;
k = 0;
d = zeros(1,2*noPulses+1);


pos_fig = [500 500  400 800];
fig = figure();
set(fig, 'Color', 'white', 'position', pos_fig)
subplot(2,1,1)
imagesc(MM)
ylabel('Active Pulses')
xlabel('Passive Pulses')
xticks(1:1:noPulses)
yticks(1:1:noPulses)

subplot(2,1,2)
for i = -noPulses:1:noPulses
    k = k+1;
    d(k) = mean(diag(MM, i));
end
peak = find(d==max(d))-noPulses-1;
plot(-noPulses:1:noPulses, d, 'k-o')
hold on
plot([0, 0], [0, 1], 'k--')
hold on
plot([peak, peak], [0, max(d)], 'r--')
hold on
scatter(peak, max(d), 'r', 'filled')
xlabel('Super Diagonal')
ylabel('Mean Value of Super Diagional')
% export_fig(['/media/brehm/Data/Panama/DataForPaper/', figname, '.png'], '-r300', '-q101')
% close

%% Sample Correlation Coefficient
% based on: https://math.stackexchange.com/questions/1392491/measure-of-how-much-diagonal-a-matrix-is
A = MM;
d = length(A);
j = ones(1, d);
r = 1:d;
r2 = r.^2;

n = j*A*j'; % sum of entries of MM
x = r*A*j'; % sum of x
y = j*A*r'; % sum of y
x2 = r2*A*j'; % sum of x^2
y2 = j*A*r2'; % sum of y^2
xy = r*A*r'; % sum of x*y

cor = (n*xy - x*y)/(sqrt(n*x2 - x.^2) * sqrt(n*y2 - y.^2));
disp(cor)

%% Norm method
A = MM;
A1 = diag(diag(A));

b = norm(A-A1);
disp(b)

%% Correlate A and A transposed
[a, p] = corrcoef(A,A');

%% Uniform Distribution (from a to b)
a = 0;
b = 1;
% uni = -a + (a+b)*rand(1,length(d));
jitter = -std(d) + (2*std(d))*rand(1,length(d));
uni = zeros(1, length(d))+mean(d)+jitter;
[h,p,ks2stat] = kstest2(uni,d);
disp(['p = ', num2str(p)])

%% Histograms
bin_width = 0.1;
edges = 0:bin_width:1;
histogram(d, edges)
hold on
histogram(uni, edges)
