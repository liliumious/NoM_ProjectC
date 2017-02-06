function source_int_plot(subjectNumber,currentDirectory,source_int)
    cd(currentDirectory);
    outputpath = strcat('subjects\sub',subjectNumber,'\');
    
    aalpath = 'ROI_MNI_V4.nii';
    aal = ft_read_atlas(aalpath);
    aal = ft_convert_units(aal,'cm');

    cfg = [];
    cfg.interpmethod = 'nearest';
    cfg.parameter = 'tissue';
    source_aal = ft_sourceinterpolate(cfg, aal, source_int);
    cfg = [];
    parcel = ft_sourceparcellate(cfg, source_aal, aal);
    
    cfg          = [];
    cfg.method   = 'interactive';
    cfg.coordsys = 'spm';
    source_int_mni = ft_volumerealign(cfg,source_int)
    
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