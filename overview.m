path = 'D:\Masterarbeit\2018-01-12\Panama\DataForPaper\Castur\PK1285\sorted\12\call_nr_2\';
f_S = 'call_nr_2Spectrogram.png';
f_AA = 'call_nr_2MatrixPlot_AA.png';
f_PP = 'call_nr_2MatrixPlot_PP.png';
f_AP = 'call_nr_2MatrixPlot_AP.png';

S = imread([path, f_S]);
AA = imread([path, f_AA]);
PP = imread([path, f_PP]);
AP = imread([path, f_AP]);

I = {AA, S, PP, AP};

%%
save_figs = 1;
 nRows = 2 ;
 nCols = 2 ;
 % - Create figure, set position/size to almost full screen.
 figure() ;
 set( gcf, 'Units', 'normalized', 'Position', [0.1,0.1,0.8,0.8], 'Color', 'white') ;
 % - Create grid of axes.
 [blx, bly] = meshgrid( 0.05:0.9/nCols:0.9, 0.05:0.9/nRows:0.9 ) ;
 hAxes = arrayfun( @(x,y) axes( 'Position', [x, y, 0.9*0.9/nCols, 0.9*0.9/nRows] ), blx, bly, 'UniformOutput', false ) ;
 % - "Plot data", update axes parameters.
 for k = 1 : numel( hAxes )
    axes( hAxes{k} ) ;
    image( I{k} ) ;
    set( gca, 'Visible', 'off' ) ;
    axis equal
 end
 
 figname = [path, 'overview.png'];
 if save_figs == 1
     export_fig(figname, '-r300', '-q101')
     close
 end
 disp('overview saved')
%% Plot
% figure()
% subplot(2,2,1)
% image(S)
% axis off
% subplot(2,2,2)
% image(AA)
% axis off
% subplot(2,2,3)
% image(PP)
% axis off
% subplot(2,2,4)
% image(AP)
% axis off