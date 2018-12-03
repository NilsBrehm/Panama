function plot_xcorr(active, lags, maxcorr, crosscorrelation, noPulses)
p = 1;
for ii = 1:noPulses
    for jj = 1:noPulses
        subplot(noPulses,noPulses,p)
        plot([lags(ii, jj), lags(ii, jj)], [-12, 12], '-r', 'LineWidth', 1.5)
        hold on;
        plot(crosscorrelation{ii,jj}(:,2), crosscorrelation{ii,jj}(:,1))
        ylim([min(min(-maxcorr)), max(max(maxcorr))])
%         [~, c] = max(abs(crosscorrelation{ii,jj}(:,1)));
%         xlim([crosscorrelation{ii,jj}(c-50,2), crosscorrelation{ii,jj}(c+50,2) ])
        if max(maxcorr(ii,:)) == maxcorr(ii,jj)
            textcolor1 = 'red';
        else
            textcolor1 = 'black';
        end
        
        text(min(min(crosscorrelation{ii,jj}(:,2))),round(max(max(active)),1),...
            ['r = ', num2str(round(maxcorr(ii, jj), 2))], 'color', textcolor1)
        text(min(min(crosscorrelation{ii,jj}(:,2))),round(max(max(active)),1)+0.2,...
            ['lag = ', num2str(round(lags(ii, jj), 2))], 'color', textcolor1)
        hold off;
        p = p+1;
    end
end
end