outpath = './sub891/';
load([outpath 'headmodel'], 'mri_unknown')

aalpath = 'ROI_MNI_V4.nii'; 

cfg          = [];
cfg.method   = 'interactive';
cfg.coordsys = 'spm';
mri_spm      = ft_volumerealign(cfg,mri_unknown)

%% Trialing on left Gyrus Rectus
aal = ft_read_atlas(aalpath);
cfg = [];
cfg.roi = 'Rectus_L';
cfg.inputcoord = 'mni';
cfg.atlas = aal;
mask = ft_volumelookup(cfg, mri_spm);


