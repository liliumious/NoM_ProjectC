function source_interpolate(subjectNumber, datapath, currentDirectory,tasknum)
    cd(currentDirectory);
    outputpath = strcat('subjects\sub',subjectNumber,'\');

    load([outputpath 'headmodel'],'mri_neuro')
    load([outputpath 'sourcemodel'],'source')

    aalpath = 'ROI_MNI_V4.nii';
    aal = ft_read_atlas(aalpath);

    cfg           = [];
    cfg.parameter = 'avg.pow';
    source_int  = ft_sourceinterpolate(cfg, source{tasknum},mri_neuro)
    save([outputpath 'intepolated'],'source_int')

    cfg          = [];
    cfg.method   = 'interactive';
    cfg.coordsys = 'spm';
    source_int_mni = ft_volumerealign(cfg,source_int)
    save([outputpath 'intepolated'],'source_int_mni','-append')

    cfg = [];
    cfg.method        = 'ortho';
    cfg.funparameter  = 'avg.pow';
    cfg.maskparameter = cfg.funparameter;
    cfg.funcolorlim   = [2.5 3.5];
    cfg.opacitylim    = [2.5 3.5]; 
    cfg.opacitymap    = 'rampup';  
    cfg.atlas = aal;
    ft_sourceplot(cfg, source_int_mni);

end