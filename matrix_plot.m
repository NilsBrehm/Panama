function matrix_plot(input, noPulsesA, noPulsesP, colorbarlabel, labelx, labely, limit, showvalues)
% This function creates a matrix plot using the Similarity Values in the
% input matrix.
% Copyright Nils Brehm 2017

if nargin < 7
    limit = [min(min(input)), max(max(input))];
    showvalues = false;
end

imagesc(input); c = colorbar('xlim', limit, 'Fontsize',5, 'FontName', 'Times');

if showvalues
    for j= 1:noPulsesA
        for k = 1:noPulsesP
            text(k-.2,j,num2str(round(input(j,k),2)), 'color', 'red', 'FontName', 'Times', 'FontSize', 2.5)
        end
    end
end
% axis xy
set(gca, 'Fontsize', 3, 'FontName', 'Times') % Font Size of tick values
xlabel(labelx, 'FontSize', 5, 'FontName', 'Times')
ylabel(labely, 'FontSize', 5, 'FontName', 'Times')
xticks(1:1:noPulsesP);
yticks(1:1:noPulsesA);
c.Label.String = colorbarlabel;
caxis([limit(1)+0.4, limit(2)]);
%title(heading)
set(c,'YTick',[limit(1):.2:limit(2)])
end