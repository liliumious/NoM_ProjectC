cfg           = [];
cfg.parameter = 'avg.mom';
source_int  = ft_sourceinterpolate(cfg, source, mri_neuro);

cfg          = [];
cfg.method   = 'interactive';
cfg.coordsys = 'spm';
source_int_mni = ft_volumerealign(cfg,source_int)

aalpath = 'ROI_MNI_V4.nii';
aal = ft_read_atlas(aalpath); 

% cfg                    = [];
% cfg.funparameter       = 'brain';
% cfg.atlas              = aal;
% cfg.colorbar           = 'no';
% % cfg.roi                = 'Supp_Motor_Area_L';
% 
% ft_sourceplot(cfg, source_int_mni);

cfg              = [];
cfg.method       = 'slice';

cfg.funparameter = 'avg.pow';
figure
ft_sourceplot(cfg,source_int);

sourcenew = source;
sourcenew.avg.pow = source.avg.pow ./ source.avg.noise;
 
cfg = [];
cfg.parameter = 'avg.pow';
source_int2 = ft_sourceinterpolate(cfg, sourcenew, mri_neuro);

cfg = [];
cfg.method        = 'slice';
cfg.funparameter  = 'avg.pow';
cfg.maskparameter = cfg.funparameter;
cfg.funcolorlim   = [4.0 6.2];
cfg.opacitylim    = [4.0 6.2]; 
cfg.opacitymap    = 'rampup';  
figure
ft_sourceplot(cfg, source_int2);

cfg = [];
cfg.roi = 'Rectus_L';
cfg.inputcoord = 'mni';
cfg.atlas = aal;
mask = ft_volumelookup(cfg, source_int_mni);