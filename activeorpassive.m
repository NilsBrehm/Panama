function samples = activeorpassive(x, th_factor, locs_ps, fs, limit, filter_pulse, method, apriori, show_plot)


% Find Start of Pulse and discriminate between active and passive
% The pulse need to be detected beforehand.
peaks = zeros(2, length(locs_ps));
found_pulses = zeros(1, length(locs_ps));
for i = 1:length(locs_ps)
    pulse = x(locs_ps(i)-limit:locs_ps(i)+limit);
    if strcmp(method, 'diff')
        pulse = diff(pulse);
    end
    if filter_pulse
        pulse = bandpassfilter_data(pulse, 1000, 150*1000, 2, fs, true, true);
    end
    th = th_factor * mad(pulse);
    [locsA, ~] = peakseek(pulse, 1, th);
    [locsP, ~] = peakseek(-pulse, 1, th);
    
    pA = locsA(1);
    pP = locsP(1);
    
    % 0 = active, 1 = passive
    if pA < pP
        peaks(1, i) = pA;
        peaks(2, i) = 0;
        tlt = 'active';
    else
        peaks(1, i) = pP;
        peaks(2, i) = 1;
        tlt = 'passive';
    end
    
    if show_plot(1)
        subplot(2,1,1)
        plot(pulse)
        hold on
        plot(locsA, pulse(locsA), 'ko')
        hold on
        plot(pA, pulse(pA), 'ro')
        hold on
        plot([1, length(pulse)], [th, th], 'r--')
        title(tlt)
        hold off
        
        subplot(2, 1, 2)
        plot(pulse)
        hold on
        plot(locsP, pulse(locsP), 'ko')
        hold on
        plot(pP, pulse(pP), 'bo')
        hold on
        plot([1, length(pulse)], [-th, -th], 'r--')
        hold off
        waitforbuttonpress;
    end
    % recalculate original position
    
    if apriori
        found_pulses(1, i) = locs_ps(i) - ((limit+1) - pA);
        found_pulses(2, i) = locs_ps(i) - ((limit+1) - pP);
    else
        found_pulses(1, i) = locs_ps(i) - ((limit+1) - peaks(1, i));
        found_pulses(2, i) = peaks(2, i);
    end
    %    % CrosCorrleation with Sinus
    %    [r1, r2] = avsp_sincorr(pulse, 1/(480*1000));
    %    if r1 > 0
    %        disp('active')
    %        disp(r1)
    %        disp(r2)
    %    else
    %        disp('passive')
    %        disp(r1)
    %        disp(r2)
    %    end
    %
end



% Apriori assumption that the first half of the call contains only active
% pulses and the second half only passive pulses
if apriori
    s = sort(found_pulses(1,:));
    d = diff(s);
    idx = find(d > 2000);
    samples.active = found_pulses(1, 1:idx(1));
    samples.passive = found_pulses(2, idx(1)+1:end);
else
    samples.active = found_pulses(1, found_pulses(2,:) == 0);
    samples.passive = found_pulses(1, found_pulses(2,:) == 1);
end

if show_plot(2)
    figure()
    plot(x, 'k'); hold on; plot(samples.active, x(samples.active), 'ro'); hold on;
    plot(samples.passive, x(samples.passive), 'bo');
    k = waitforbuttonpress;
    if k == 1
        close all
    end
end


end
