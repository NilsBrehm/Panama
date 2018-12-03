function fig = plot_methods(active, mat)
% Plots all 4 methods: Active vs. Passive
fields = fieldnames(mat);
noPulses = size(active,2);

% Set common colormap range for raw, env and spc
bottom = min([min(min(min(mat.raw))), min(min(min(mat.env))), min(min(min(mat.spc)))]);
top = max([max(max(max(mat.raw))), max(max(max(mat.env))), max(max(max(mat.spc)))]);

% SubPlot
fig = figure();
for i=1:numel(fields)
    subplot(2,2,i)
    imagesc(mat.(fields{i}))
    %axis equal
    axis xy
    xlabel("Passive click #")
    ylabel("Active click #")
    xticks(1:1:noPulses);
    yticks(1:1:noPulses);
    title(fields(i))
    if i == 3
        c = colorbar('xlim', [0, max(max(mat.phc))]);
    else
        c = colorbar('xlim', [0, 1], 'ticks', linspace(0, 1, 11));
        caxis manual
        caxis([bottom top])
    end
    c.Label.String = 'Correlation';
    colormap parula
end
end
