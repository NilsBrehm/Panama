[Cxy,f] = mscohere(pulses.active(:,2),pulses.active(:,4),[],[],[],480000);
plot(f,Cxy)
xlim([0, 100000])

%%
lg = {};
for i = 1:9
x = pulses.active(:,10);
y = pulses.passive(:,i);
[cxy(:,i),fc] = mscohere(x,y,hamming(50),10,2048,480000);
plot(fc, cxy(:,i))
hold on
lg{i} = num2str(i);
end
xlim([0 100000])
legend(lg)

SumC = sum(cxy(1:300,:));
ind = SumC == max(SumC);
passivematch = find(ind);
disp(passivematch)