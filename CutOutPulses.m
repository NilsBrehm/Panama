function [time, pulses, envs, phas, repulses, reenvs, rephas]...
    = CutOutPulses(data, samples, pulsewindowstart, pulsewindowend, ...
    baseline, samplingrate)
% This function cuts out single pulses from a single call
% 
% Copyright Francisco Cervantes Constantino and Nils Brehm 2018

% noPulses=size(samples.active,2);
% -------------------------------------------------------------------------
%time=1000*[-27:134]/256000;
time=1000*[pulsewindowstart:pulsewindowend]/samplingrate;

% Compute active single pulses
for i=1:length(samples.active)
    temp(:,i)=data(samples.active(i)+pulsewindowstart:samples.active(i)+pulsewindowend);
    % Remove y-offset
    temp(:,i)=temp(:,i)-mean(temp(1:baseline,i));
end
pulses.active=temp;clear temp

% Compute passive single pulses
for i=1:length(samples.passive)
    temp(:,i)=data(samples.passive(i)+pulsewindowstart:samples.passive(i)+pulsewindowend);
    % Remove y-offset
    temp(:,i)=temp(:,i)-mean(temp(1:baseline,i));
end
pulses.passive=temp;clear temp


% Compute Envelope of single pulses using hilbert transform
envs.active=abs(hilbert(pulses.active));
envs.passive=abs(hilbert(pulses.passive));
phas.active=(angle(hilbert(pulses.active)));
phas.passive=(angle(hilbert(pulses.passive)));

% Invert and Flip passive pulses
repulses=fliplr(-pulses.passive);
reenvs=fliplr(envs.passive);
rephas=fliplr(phas.passive);

% mean phase coherence values between the click recording fine structures
% for abc=1:noPulses
%     for def=1:noPulses
%         mat.phc(abc,def)=abs(mean(exp(1i*(phas.active(windowstart:windowend,abc)-rephas(windowstart:windowend,def)))));
%         temp1(abc,def)=abs(mean(exp(1i*(phas.active(windowstart:windowend,abc)-phas.active(windowstart:windowend,def)))));
%         temp2(abc,def)=abs(mean(exp(1i*(rephas(windowstart:windowend,abc)-rephas(windowstart:windowend,def)))));
%     end
% end

% ref1.phc=(temp1+temp1)/2;
% ref2.phc=(temp2+temp2)/2;
% ref.phc=triu(ref1.phc)+tril(ref2.phc);ref.phc(ref.phc>1)=NaN;

% % Poly Fit
% FIT_active = fit_pulses(pulses.active, windowstart, windowend, 20);
% FIT_passive =  fit_pulses(repulses, windowstart, windowend, 20);

end