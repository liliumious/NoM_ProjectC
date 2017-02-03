ts_all = zeros(1678,561000);
j = 1;

for i=1:3332
    if source.inside(i)
        disp([i j])
        ts_all(j,:) = source.avg.mom{i};
        j = j+1;
    end
end

% chns = sort(randi(1678,1,10));
chns = 830:839;
k=5e-12;
figure
hold on 
for i=chns
    add = i*k;
    if length(source.avg.mom{i})~=201
        continue
    end
    plot(1:201,source.avg.mom{i}+add)
    set(gca,'Ytick', [])
end
hold off
