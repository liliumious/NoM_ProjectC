function source_int = source_interpolate(subjectNumber,currentDirectory,tasknum)
    cd(currentDirectory);
    outputpath = strcat('subjects\sub',subjectNumber,'\');

    load([outputpath 'headmodel'],'mri_neuro')
    load([outputpath 'sourcemodel'],'source')
    
    cfg           = [];
    cfg.parameter = 'avg.pow';
    source_int  = ft_sourceinterpolate(cfg, source{tasknum},mri_neuro)
end