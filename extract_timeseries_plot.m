ts_all = zeros(1678,541000);
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
time = 200000:260000;
k=5e-12;
figure
hold on 
for i=1:length(chns)
    add = i*k;
    plot(source.time(time),ts_all(chns(i),time)+add)
    set(gca,'Ytick', [])
end
hold off
