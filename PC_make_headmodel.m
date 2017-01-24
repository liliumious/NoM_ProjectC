mkdir('.\sub891\');
outputpath = '.\sub891\';

cd('C:\Users\Lily\Documents\NoM_ProjectC')
addpath C:\Users\Lily\Dropbox\NetworkofMind\fieldtrip
ft_defaults

datapath = 'C:\Users\Lily\Dropbox\NetworkofMind';
mripath = [datapath '\MRI_anatomy\sub-CC722891\anat\sub-CC722891_T1w.nii'];
megpath = [datapath '\MEG_Resting\sub-CC722891\meg\rest_raw.fif'];

%% Head Model
mri_unknown = ft_read_mri(mripath)
mri_unknown = ft_determine_coordsys(mri_unknown, 'interactive', 'yes');
save([outputpath 'headmodel'],'mri_unknown')

% % This automated method doesn't seem to produce a viable brain
% cfg=[];
% cfg.method='spm';
% cfg.coordsys='spm';
% target = ft_read_mri('MNI152_T1_1mm.img');
% mri_spm = ft_volumerealign(cfg,mri_unknown,target)
% save mri_spm mri_spm
 
cfg          = [];
cfg.method   = 'interactive';
cfg.coordsys = 'neuromag';
mri_neuro    = ft_volumerealign(cfg,mri_unknown)
save([outputpath 'headmodel'],'mri_neuro','-append')

% Note this brain has not been normalised! Todo before comparing to other
% patients

cfg           = [];
cfg.output    = 'brain';
segmentedmri  = ft_volumesegment(cfg, mri_neuro);
save([outputpath 'headmodel'],'segmentedmri','-append')

cfg        = [];
cfg.method = 'singleshell';
vol        = ft_prepare_headmodel(cfg, segmentedmri);
vol        = ft_convert_units(vol,'cm');
save([outputpath 'headmodel'],'vol','-append')

% Cannot plot due to coordsys mismatch between atlas and mri
% aalpath = 'ROI_MNI_V4.nii'; 
% aal = ft_read_atlas(aalpath);
% cfg                    = [];
% cfg.funparameter       = 'brain';
% cfg.atlas              = aal;
% cfg.roi           = 'Rectus_L';
% segmentedmri.anatomy   = mri_neuro.anatomy;
% ft_sourceplot(cfg, segmentedmri);
