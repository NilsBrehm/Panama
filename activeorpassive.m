function [samples, pulse_duration, freq, freq_range, power] = activeorpassive(x, th_factor, locs_ps, fs, limit_left, limit_right, env_th_factor, filter_pulse, method, apriori, show_plot)


% Find Start of Pulse and discriminate between active and passive
% The pulse need to be detected beforehand.
peaks = zeros(2, length(locs_ps));
found_pulses = zeros(1, length(locs_ps));
pulse_duration = zeros(1, length(locs_ps));
freq = zeros(1, length(locs_ps));
freq_range = zeros(length(locs_ps), 2);
power = zeros(1, length(locs_ps));
i = 1;

while i <= length(locs_ps)
    pulse = x(locs_ps(i)-limit_left:locs_ps(i)+limit_right);
    if strcmp(method, 'diff')
        pulse = diff(pulse);
    end
    if filter_pulse
        pulse = bandpassfilter_data(pulse, 1000, 150*1000, 2, fs, true, true);
    end
    th = th_factor * mad(pulse);
    [locsA, ~] = peakseek(pulse, 1, th);
    [locsP, ~] = peakseek(-pulse, 1, th);
    
    try
        pA = locsA(1);
        pP = locsP(1);
    catch
        uiwait(warndlg('Unable to detect pulses, try to use different detection settings', 'Detection Error'));
    end
    
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
    try
        pulse_long = x(locs_ps(i)-limit_left:locs_ps(i)+limit_right+100);
        env = envelope(pulse_long);
        env_th = env_th_factor * mad(pulse_long, 1);
        pulse_ends = find(env(peak_long:end) <= env_th);
        pulse_stop = pulse_ends(1) + peak_long;
        
        pulse_duration(i) = abs(peak_long-pulse_stop);
    catch
        uiwait(warndlg('Pulse duration detection failed, try to use a different envelope threshold value',...
            'Detection Error'));
    end
    
    % Frequency Components
    try
        pulse_freq = pulse_long(peak_long-5:pulse_stop);
        [Pd,f1] = periodogram(pulse_freq,[],512,fs,'power');
        [pos, maxpower] = peakseek(Pd, 10, mean(Pd));
        maxfreqs = f1(pos);
        %ll = [max(maxpower), max(maxpower(maxpower<max(maxpower)))];
        %maxfreqs = [maxfreqs(maxpower == ll(1)), maxfreqs(maxpower == ll(2))];
        %maxpower = ll;
        P1 = 10 * log10(Pd); % to get db values
        [power(i), b] = max(P1);
        freq(i) = f1(b);
        ff = f1(P1 >= mean(P1)+std(P1));
        freq_range(i, 1) = min(ff) / 1000;
        freq_range(i, 2) = max(ff) / 1000;
        
    catch
        uiwait(warndlg('Error in Frequency Analysis, please try different settings',...
            'Frequency Error'));
    end
    
    % Plot
    if show_plot(1)
        try
            fig = figure(1);
            pos_fig = [200 500 400 1000];
            set(fig, 'Color', 'white', 'position', pos_fig)
            % Plot Active Pulse Detection
            subplot(5, 1, 1)
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
            
            % Plot Passive Pulse Detection
            subplot(5, 1, 2)
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
            
            % Plot Envelope to show pulse duration estimate
            subplot(5, 1, 3)
            plot(pulse_long);hold on; plot(env); hold on;
            plot([1, length(pulse_long)], [env_th, env_th], 'r--'); hold on;
            plot(peak_long, pulse_long(peak_long), 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
            hold on;
            plot(pulse_stop, pulse_long(pulse_stop), 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'r')
            xlabel('Samples')
            ylabel('Amplitude')
            hold off
            
            % Plot Power vs Frequency
            subplot(5, 1, 4)
            periodogram(pulse_freq,[],512,fs,'power')
            hold on
            plot(f1(b)/1000, P1(b), 'ro')
            hold on
            plot([freq_range(i, 1), freq_range(i, 1)],[min(P1), max(P1)] , 'r--')
            hold on
            plot([freq_range(i, 2), freq_range(i, 2)],[min(P1), max(P1)] , 'r--')
            hold on
            plot(maxfreqs/1000, 10 * log10(maxpower), 'bo')
            title('')
            xlim([0 200])
            set(gca, 'YScale', 'log')
            hold off
            
            % Plot Spectrogram
            subplot(5, 1 ,5)
            compute_spectrogram(pulse_freq, fs, P1)
            hold off
            
            figure(5)
            hold off
            plot(x, 'k')
            hold on
            plot(locs_ps(i), x(locs_ps(i)), 'mo', 'MarkerSize', 8, 'MarkerFaceColor', 'm')
            if i > 1
                hold on
                cc = peaks(2, i-1)+1;
                ccolor = {'ro', 'bo'};
                plot(locs_ps(i-1), x(locs_ps(i-1)), ccolor{cc}, 'MarkerSize', 8)
            end
        catch
            uiwait(warndlg('Something went wrong during plotting, please try again using different settings',...
                'Plotting Error'));
            hold off
        end
        
        % do not move on until enter key is pressed
        currkey=0;
        repeat = 0;
        while currkey~=1
            pause; % wait for a keypress
            currkey=get(gcf,'CurrentKey');
            if strcmp(currkey, 'return') % All good
                currkey=1;
            elseif strcmp(currkey, 'r') % One pulse back
                repeat = 2;
                currkey=1;
            elseif strcmp(currkey, 'c') % Enter Correction Mode
                prompt = {'Threshold Factor:','Limit Left:','Limit Right:','Envelope Threshold Factor'};
                dlg_title = 'Detection Settings';
                num_lines = 1;
                defaultans = {num2str(th_factor), num2str(limit_left), num2str(limit_right), num2str(env_th_factor)};
                answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                limit_left = str2double(answer{2});
                limit_right = str2double(answer{3});
                th_factor = str2double(answer{1});
                env_th_factor = str2double(answer{4});
                currkey=1;
                repeat = 1;
            elseif strcmp(currkey, 'z') % Enter Zoom Mode
                pulse_verylong = x(locs_ps(i)-(limit_left+50):locs_ps(i)+limit_right+150);
                fig2 = figure(3);
                pos_fig = [500 500 800 600];
                set(fig2, 'Color', 'white', 'position', pos_fig)
                % plot(pulse_long, 'k')
                plot(pulse_verylong);hold on; plot(50:length(env)+49, env); hold on;
                plot([1, length(pulse_verylong)], [env_th, env_th], 'r--'); hold on;
                plot(peak_long+50, pulse_verylong(peak_long+50), 'ro', 'MarkerSize', 10);
                hold on;
                plot(pulse_stop+50, pulse_verylong(pulse_stop+50), 'rx', 'MarkerSize', 10)
                xlabel('Samples')
                ylabel('Amplitude')
                hold off
                waitforbuttonpress
                close(figure(3))
                currkey=0;
            elseif strcmp(currkey, 'p') % Enter Zoomed Periodogram
                fig4 = figure(4);
                pos_fig = [500 500 800 600];
                set(fig4, 'Color', 'white', 'position', pos_fig)
                periodogram(pulse_long,[],[],fs,'power')
                hold on
                plot(f1(b)/1000, P1(b), 'ro')
                title('')
                hold off
                waitforbuttonpress
                close(figure(4))
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
    else
        repeat = 0;
    end
    
    
    if repeat == 1
        continue;
    elseif repeat == 2
        if i-1 > 0
            i = i-1;
        end
        continue
    end
    
    % recalculate original position
    if apriori
        found_pulses(1, i) = locs_ps(i) - ((limit_left+1) - pA);
        found_pulses(2, i) = locs_ps(i) - ((limit_left+1) - pP);
    else
        found_pulses(1, i) = locs_ps(i) - ((limit_left+1) - peaks(1, i));
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
    % uiwait(warndlg('Ups, something went wrong, try again.', 'Error'));
    
end

% Apriori assumption that the first half of the call contains only active
% pulses and the second half only passive pulses
if isempty(found_pulses)
    disp('No Pulses were found and recording was dismissed')
    samples = []; pulse_duration = []; freq = []; power = [];
    return
end
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
    figure(5)
    hold off
    plot(x, 'k'); hold on; plot(samples.active, x(samples.active), 'ro'); hold on;
    plot(samples.passive, x(samples.passive), 'bo');
    title(['A: ', num2str(length(samples.active)), ' and ', 'P: ', num2str(length(samples.passive))])
    hold off
    close(figure(1))
    % do not move on until enter key is pressed
    currkey=0;
    redo = 0;
    while currkey~=1
        pause; % wait for a keypress
        currkey=get(gcf,'CurrentKey');
        if strcmp(currkey, 'return') % All good
            %             figure(5)
            %             title('Press "n" to redo pulse detection')
            currkey=1;
        elseif strcmp(currkey, 'r') % Go back and do it again
            prompt = {'Threshold Factor:','Limit Left:','Limit Right:','Envelope Threshold Factor'};
            dlg_title = 'Detection Settings';
            num_lines = 1;
            defaultans = {num2str(th_factor), num2str(limit_left), num2str(limit_right), num2str(env_th_factor)};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
            limit_left = str2double(answer{2});
            limit_right = str2double(answer{3});
            th_factor = str2double(answer{1});
            env_th_factor = str2double(answer{4});
            redo = 1;
            currkey=1;
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

if redo == 1
    [samples, pulse_duration, freq, power] = activeorpassive(x, th_factor,...
        locs_ps, fs, limit_left, limit_right, env_th_factor, filter_pulse, method, apriori, ...
        show_plot);
end

end
