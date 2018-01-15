function plot_raw_pulses(active, passive, similarity1, similarity2, matched)
% Plot raw pulses in a matrix as comparison
% If Matching pairs are a1 - p1 and so on... (repulses) than machted = 1,
% else matched = 0.
% -------------------------------------------------------------------------
% figure('units','normalized','outerposition',[0 0 1 1]);
noPulses = size(active,2);
p = 1;
for i = 1:noPulses
    for k = 1:noPulses
        subplot(noPulses,noPulses,p)
        plot(active(:,i), 'red')
        hold on
        plot(passive(:,k), 'blue')
        if k == 1
            ylabel(["A", num2str(i), ' '], 'fontsize', 12, 'FontWeight', 'bold', 'Color','red')
        end
        set(get(gca,'ylabel'),'rotation',0)
        if matched == 1
             if max(similarity1(i,:)) == similarity1(i,k)
                textcolor1 = 'red';
            else
                textcolor1 = 'black';
            end
            if min(similarity2(i,:)) == similarity2(i,k)
                textcolor2 = 'red';
            else
                textcolor2 = 'black';
            end
            text(0, 0.6, ['r = ', num2str(round(similarity1(i,k),2))], 'color', textcolor1) % plot raw correlation
            text(0, 0.4, ['MSE = ', num2str(round(similarity2(i,k),2))], 'color', textcolor2) % plot raw correlation
        else
            dummy = fliplr(similarity);
            text(10, 0, ['r = ', num2str(round(dummy(i,k),2))]) % original oder as marked
        end
        if p  <= noPulses
            if matched == 1
                title(["P", num2str(k), 'matched'], 'Color', 'blue')
            else
                title(["P", num2str(k), 'unmatched'], 'Color', 'blue')
            end
        end
        hold off
        p = p+1;
    end
end
end