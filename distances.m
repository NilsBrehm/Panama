function [euclidean, normalized] = distances(active, passive, windowstart, windowend)

noPulses = size(active,2);
% Get only the impulse zone of the click
a_impulse_zone = zeros((windowend-windowstart+1),noPulses);
p_impulse_zone = zeros((windowend-windowstart+1),noPulses);

for i = 1:noPulses
    a_impulse_zone(:,i) = active(windowstart:windowend,i);
    p_impulse_zone(:,i) = passive(windowstart:windowend,i);
end

% Now calculate distances
euclidean = zeros(noPulses, noPulses);
euclidean_AvsA =  zeros(noPulses,noPulses);
for k = 1:noPulses
    for j = 1:noPulses
        euclidean(k,j)= sqrt(sum(((a_impulse_zone(:,k)-p_impulse_zone(:,j)).^2)));
        euclidean_AvsA(k,j) = sqrt(sum(((a_impulse_zone(:,k)-a_impulse_zone(:,j)).^2)));
    end
end

% Normalize
normalized = euclidean./(mean(euclidean_AvsA, 2));

end