mkdir('./sub891/');
outputpath = './sub891/';

cd('/Users/Lily/Documents/Networkofmind')
addpath /Users/Lily/Documents/Networkofmind/fieldtrip
ft_defaults

mripath = './MEGCanCam/MRI anatomy/sub-CC722891/anat/sub-CC722891_T1w.nii';
megpath = './MEGCanCam/MEG Resting/sub-CC722891/meg/rest_raw.fif';

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
