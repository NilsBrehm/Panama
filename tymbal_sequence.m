%% Find Tymbal Activation Sequence
% pulse time | active or passive (0 or 1) | pulse id (pulse order) | tymbal nr 
ids_a = linspace(1,length(samples.active),(length(samples.active)));
ids_p = linspace(1,length(samples.passive),(length(samples.passive))); 
a = [samples.active; zeros(1, length(samples.active)); ids_a ];
p = [samples.passive; ones(1, length(samples.passive)); ids_p];

allpulses = sortrows([a, p]');
k = 1;
for i=1:length(allpulses)
    if allpulses(i, 2) == 0
        tymbal(i) = k;
        k = k+1;
    else
        tymbal(i) = k-1;
        k = k-1;
    end

end
allpulses(:, 4) = tymbal;

%% Find pulses associated to stria
stria_count = max(allpulses(:,4));
stria = cell(stria_count, 2);
for q = 1:stria_count
    stria{q, 1} = allpulses((allpulses(:, 4) == q & allpulses(:, 2) == 0), 3)';
    stria{q, 2} = allpulses((allpulses(:, 4) == q & allpulses(:, 2) == 1), 3)';
    disp(['STRIA: ', num2str(q)]) 
    disp('active id')
    disp(stria{q, 1})
    disp('passive id')
    disp(stria{q, 2})
    disp('------------')
end

%% Best match concerning correlation
clc
active_matches = zeros(size(MaxCorr_AP,1), 1);
for i = 1:size(MaxCorr_AP,1)
    [row, col] = find(MaxCorr_AP == max(MaxCorr_AP(i,:)));
    active_matches(i) = col;
end

passive_matches = zeros(size(MaxCorr_AP,2), 1);
for i = 1:size(MaxCorr_AP,2)
    [row, col] = find(MaxCorr_AP == max(MaxCorr_AP(:,i)));
    passive_matches(i) = row;
end

disp('Active Matches:')
disp([[1:size(MaxCorr_AP,1)]', active_matches])
disp('Passive Matches:')
disp([[1:size(MaxCorr_AP,2)]', passive_matches])
