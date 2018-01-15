pathname = '/media/brehm/Data/Panama/data/new_carales_recs/Castur/PK1285/Pk12850008/call_nr_';
% A = cell(10,1);
ideal = cell(1, 10);
error = cell(1, 10);
MC = zeros(17,17);
n = 0;
for j = 1:10
    A = load([pathname, num2str(j), '/call_nr_', num2str(j), '.mat'], 'MaxCorr_AP');
    val = zeros(1, size(A.MaxCorr_AP, 1));
    row = zeros(1, size(A.MaxCorr_AP, 1));
    for i = 1:size(A.MaxCorr_AP, 1)
        [val(i), row(i)] = max(A.MaxCorr_AP(i,:));
    end
    
    ideal{j} = size(A.MaxCorr_AP, 1):-1:1;
    error{j} = row-ideal{j};
    
    if size(A.MaxCorr_AP) == [17, 17]
        n = n+1;
        MC = MC + A.MaxCorr_AP;
    end
    
end
MC = MC/n;
%%
figure()    
plot(1:noPulsesA, row, 'k--o')
hold on
plot(1:noPulsesA, ideal, 'r-o')
hold on
for k = 1:noPulsesA
    plot([k, k], [ideal(k), ideal(k)+error(k)], 'g')
    hold on
end

xlabel('Active Pulse Number')
ylabel('Passive Pulse Number Best Fit')
xticks(1:noPulsesA)
yticks(1:noPulsesP)

%%
figure()
bar(1:noPulsesA, abs(error))
xlabel('Active Pulse Number')
ylabel('Absolute deviation from ideal diagonal')

%%
pnumber = 17;
xtitle = 'Passive';
ytitle = 'Active';
 pos_fig = [100 100 8 8];
    fig = figure('Visible', displayfigs);
    set(fig, 'Color', 'white', 'Units', 'centimeters', 'position', pos_fig)
    matrix_plot(MC, pnumber, pnumber, 'Max. Cross Correlation [r]', ...
        xtitle, ytitle, [0, 1]);
    axis equal; xlim([0.5 pnumber+0.5]); ylim([0.5 pnumber+0.5]); box off; axis xy;