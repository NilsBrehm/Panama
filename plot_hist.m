function plot_hist(data1, data2, bin_width, labelx, labely, legend_label)
% figure()
bins_1 = ceil(max(data1)/bin_width);
bins_2 = ceil(max(data2)/bin_width);
histogram(data1, bins_1, 'Normalization', 'probability')
hold on
histogram(data2, bins_2, 'Normalization', 'probability')
xlabel(labelx)
ylabel(labely)
legend(legend_label)
end