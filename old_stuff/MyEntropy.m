function [E1, E2] = MyEntropy(data)
p = data./sum(sum(data));

E1 = zeros(size(data,1), size(data,2));
E2 = E1;
for i = 1:size(data,1)
    E1(i,:) = -sum(p(i,:) .* log2(p(i,:)));
    E2(:,i) = -sum(p(:,i) .* log2(p(:,i)));
end

subplot(1,4,1)
imagesc(data)
subplot(1,4,2)
imagesc(E1)
subplot(1,4,3)
imagesc(E2)
subplot(1,4,4)
imagesc((E1+E2)./2)

figure()
subplot(2,1,1)
imagesc(data)
subplot(2,1,2)
plot(E1)
end