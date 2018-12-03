function plot_boxplot(data, group, legend_label, datalim, labely)
boxplot(data, group, 'colors', 'k', 'label', legend_label, ...
    'DataLim', datalim, 'ExtremeMode', 'compress', ...
    'widths', .5)
ylabel(labely, 'FontSize', 16)
set(gca,'XTickLabel',legend_label, 'FontSize', 16, 'LineWidth', 1.5)
box off
set(findobj(gca,'type','line'),'linew',2)
end