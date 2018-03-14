function [samples, pulse_duration, freq, power] = activeorpassive(x, th_factor, locs_ps, fs, limit, env_th_factor, filter_pulse, method, apriori, show_plot)


% Find Start of Pulse and discriminate between active and passive
% The pulse need to be detected beforehand.
peaks = zeros(2, length(locs_ps));
found_pulses = zeros(1, length(locs_ps));
pulse_duration = zeros(1, length(locs_ps));
freq = zeros(1, length(locs_ps));
power = zeros(1, length(locs_ps));
i = 1;
while i <= length(locs_ps)
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
        peak_long = pA;
        tlt = 'active';
    else
        peaks(1, i) = pP;
        peaks(2, i) = 1;
        peak_long = pP;
        tlt = 'passive';
    end
    
    
    
    % Pulse Length
    pulse_long = x(locs_ps(i)-limit:locs_ps(i)+limit+100);
    env = envelope(pulse_long);
    env_th = env_th_factor * mad(pulse_long, 1);
    pulse_ends = find(env(peak_long:end) <= env_th);
    pulse_stop = pulse_ends(1) + peak_long;
    
    pulse_duration(i) = abs(peak_long-pulse_stop);
    
    % Frequency Components
    [P1,f1] = periodogram(pulse_long,[],[],fs,'power');
    P1 = 10 * log10(P1); % to get db values
    [power(i), b] = max(P1);
    freq(i) = f1(b);
    
    % Plot
    if show_plot(1)
        fig = figure(1);
        pos_fig = [500 500 300 800];
        set(fig, 'Color', 'white', 'position', pos_fig)
        subplot(4, 1, 1)
        plot(pulse)
        hold on
        plot(locsA, pulse(locsA), 'ko')
        hold on
        plot(pA, pulse(pA), 'ro')
        hold on
        plot([1, length(pulse)], [th, th], 'r--')
        title(['Set to ', tlt])
        ylabel('Amplitude')
        xlabel('Samples')
        hold off
        
        subplot(4, 1, 2)
        plot(pulse)
        hold on
        plot(locsP, pulse(locsP), 'ko')
        hold on
        plot(pP, pulse(pP), 'bo')
        hold on
        plot([1, length(pulse)], [-th, -th], 'r--')
        xlabel('Samples')
        ylabel('Amplitude')
        hold off
        
        subplot(4, 1, 3)
        plot(pulse_long);hold on; plot(env); hold on;
        plot([1, length(pulse_long)], [env_th, env_th], 'r--'); hold on;
        plot(peak_long, pulse_long(peak_long), 'mo'); hold on;
        plot(pulse_stop, pulse_long(pulse_stop), 'mx')
        xlabel('Samples')
        ylabel('Amplitude')
        hold off
        
        subplot(4, 1, 4)
        %plot(f1, P1, 'k')
        periodogram(pulse_long,[],[],fs,'power')
        hold on
        plot(f1(b)/1000, P1(b), 'ro')
        title('')
        hold off
        
        % do not move on until enter key is pressed
        currkey=0;
        repeat = 0;
        while currkey~=1
            pause; % wait for a keypress
            currkey=get(gcf,'CurrentKey');
            if strcmp(currkey, 'return') % All good
                currkey=1;
            elseif strcmp(currkey, 'c') % Enter Correction Mode
                prompt = {'Threshold Factor:','Limit:','Envelope Threshold Factor'};
                dlg_title = 'Detection Settings';
                num_lines = 1;
                defaultans = {num2str(th_factor), num2str(limit), num2str(env_th_factor)};
                answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                limit = str2double(answer{2});
                th_factor = str2double(answer{1});
                env_th_factor = str2double(answer{3});
                currkey=1;
                repeat = 1;
            elseif strcmp(currkey, 'z') % Enter Close Up Mode
                fig2 = figure(3);
                pos_fig = [500 500 800 600];
                set(fig2, 'Color', 'white', 'position', pos_fig)
                plot(pulse_long, 'k')
                waitforbuttonpress
                close(figure(3))
                currkey=0;
            elseif strcmp(currkey, 'escape') % Exit
                disp('Exit Program')
                close all
                samples = []; pulse_duration = []; freq = []; power = [];
                return
            else
                currkey=0;
            end
        end
    end
    
    if repeat == 1
        continue;
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
    
    % If this point is reached all is good: move to the next pulse
    i = i + 1;
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
    key_pressed = waitforbuttonpress;
    if key_pressed == 1
        close all
    end
end


end
