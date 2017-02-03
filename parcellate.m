outpath = '.\sub891\';
load([outpath 'headmodel'], 'mri_unknown')

aalpath = 'ROI_MNI_V4.nii';
aal = ft_read_atlas(aalpath); 

cfg          = [];
cfg.method   = 'interactive';
cfg.coordsys = 'spm';
mri_spm      = ft_volumerealign(cfg,mri_unknown);


%% Trialing on left Gyrus Rectus


% cfg = [];
% cfg.roi = 'Rectus_L';
% cfg.inputcoord = 'mni';
% cfg.atlas = aal;
% mask = ft_volumelookup(cfg, mri_spm);

cfg           = [];
cfg.output    = 'brain';
segmri  = ft_volumesegment(cfg, mri_spm);
segmri.anatomy   = mri_spm.anatomy;

% Attempting to visualise the roi
cfg                    = [];
cfg.funparameter       = 'brain';
cfg.roi                = 'amygdala_L';
cfg.atlas              = aal;
cfg.colorbar           = 'no';

ft_sourceplot(cfg, segmri);


