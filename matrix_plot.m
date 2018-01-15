function matrix_plot(input, noPulsesA, noPulsesP, colorbarlabel, labelx, labely, limit)
if nargin < 7
    limit = [min(min(input)), max(max(input))];
end

imagesc(input); c = colorbar('xlim', limit, 'Fontsize',8, 'FontName', 'Times');

for j= 1:noPulsesA
   for k = 1:noPulsesP
   text(k-.2,j,num2str(round(input(j,k),2)), 'color', 'red', 'FontName', 'Times', 'FontSize', 2.5)
   end
end
% axis xy
set(gca, 'Fontsize', 6, 'FontName', 'Times') % Font Size of tick values
xlabel(labelx, 'FontSize', 10, 'FontName', 'Times')
ylabel(labely, 'FontSize', 10, 'FontName', 'Times')
xticks(1:1:noPulsesP);
yticks(1:1:noPulsesA);
c.Label.String = colorbarlabel;
caxis([limit(1)+0.4, limit(2)]);
%title(heading)
set(c,'YTick',[limit(1):.2:limit(2)])
end