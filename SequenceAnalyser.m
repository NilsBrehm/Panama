%%
clear maxc
Cat = {};
threshold = 0.99;
len = min(size(pulses.active, 1), size(pulses.passive, 1));
for k = 1:noPulses
    for i = 1:noPulses
        [~, maxc(k,i), lag(k,i)] = crosscorr(pulses.active(:,k), pulses.active(:,i), 1, len, 'coeff');
    end
    Cat{k} = find(maxc(k,:)>threshold);
end
disp('done')