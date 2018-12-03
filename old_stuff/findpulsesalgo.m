function [Peak, samples] = findpulsesalgo(data, thresholdA, thresholdP, pulselength, filter)
% This function uses amplitude thresholds and expected pulse length to find
% pulse starting times. It is capable of discriminating active and passive
% pulses. Thresholds need to be adjusted manually.
% 
% INPUTS:
% data: moth recording
% thresholdA: threshold for active pulses
% thresholdP: threshold for passive pulses
% pulselength: expected minimal pulse length
% filter: Use filtered data or not (1, 0)
% 
% OUTPUTS:
% Peak: pulse starting positions for all pulses in samples
% samples: Structure Array containing active and passive pulses separately
% 
% Copyright Nils Brehm 2017

k = 0;
i = 20;
ka = k;
kp = k;
if filter == 1
    while i <= length(data)-pulselength
        i = i+1;
        if (data(i) > thresholdA || data(i) < -thresholdP) && sum(data(i-20:i-5)) == 0
            k = k+1;
            Peak(k) = i;
            % Active or Passive?
            if data(i) > thresholdA
                ka = ka+1;
                j = 1;
                while data(i+j)>data(i+j-1)
                    j = j+1;
                end % Now we reached the nearby maximum
                
                %Aindex = find(data(i-2:i+2) == max(data(i-2:i+2)));
                %Aindex = i-3 + Aindex;
                Aindex = i+j-1;
                samples.active(ka) = Aindex;
            elseif data(i) < -thresholdP
                kp = kp + 1;
                j = 1;
                while data(i+j)<data(i+j-1)
                    j = j+1;
                end % Now we reached the nearby minimum
                Pindex = i+j-1;
                samples.passive(kp) = Pindex;
            end
            i = i+pulselength; % ignore rest of the data right behind the first peak (= pulse length)
        end
    end
    
else
    while i <= length(data)-pulselength
        i = i+1;
        if data(i) > thresholdA || data(i) < -thresholdP
            k = k+1;
            Peak(k) = i;
            % Active or Passive?
            if data(i) > thresholdA
                ka = ka+1;
                j = 1;
                while data(i+j)>data(i+j-1)
                    j = j+1;
                end % Now we reached the nearby maximum
                
                %Aindex = find(data(i-2:i+2) == max(data(i-2:i+2)));
                %Aindex = i-3 + Aindex;
                Aindex = i+j-1;
                samples.active(ka) = Aindex;
            elseif data(i) < -thresholdP
                kp = kp + 1;
                j = 1;
                while data(i+j)<data(i+j-1)
                    j = j+1;
                end % Now we reached the nearby minimum
                Pindex = i+j-1;
                samples.passive(kp) = Pindex;
            end
            i = i+pulselength; % ignore rest of the data right behind the first peak (= pulse length)
        end
    end
end
end