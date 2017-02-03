ts_all = zeros(1678,561000);
j = 1;

for i=1:3332
    if source.inside(i)
        ts_all(j,:) = source.avg.mom{i};
        disp([i j])
        j = j+1;
    end
end

time = 200000:202000;
plot(source.time(time),ts_all(1:10,time))