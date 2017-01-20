mripath = './MEGCanCam/MRI anatomy/sub-CC722891/anat/sub-CC722891_T1w.nii';

mri_unknown = ft_read_mri(mripath)
mri_unknown = ft_determine_coordsys(mri_unknown, 'interactive', 'yes');

cfg          = [];
cfg.method   = 'interactive';
cfg.coordsys = 'spm';
mri_spm    = ft_volumerealign(cfg,mri_unknown)

% aal = ft_read_atlas(aalpath);
% cfg = [];
% cfg.roi = 'Rectus_L';
% cfg.inputcoord = 'mni';
% cfg.atlas = aal;
% mask = ft_volumelookup(cfg, mri_spm);
% 

