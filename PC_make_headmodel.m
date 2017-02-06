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
% save([outputpath 'headmodel'],'mri_unknown')
 
cfg          = [];
cfg.method   = 'interactive';
cfg.coordsys = 'neuromag';
mri_neuro    = ft_volumerealign(cfg,mri_unknown)
% save([outputpath 'headmodel'],'mri_neuro','-append')

% headshape = ft_read_headshape(megpath);
% headshape.fid.pos = double(headshape.fid.pos);

% cfg = [];
% cfg.method = 'fiducial';
% cfg.fiducial.lpa = headshape.fid.pos(1,:); % position of LPA
% cfg.fiducial.nas = headshape.fid.pos(2,:); % position of nasion
% cfg.fiducial.rpa = headshape.fid.pos(3,:); % position of RPA
% cfg.coordsys = 'neuromag';
% mri_realigned = ft_volumerealign(cfg, mri_unknown);
% 
% cfg = [];
% cfg.method = 'headshape';
% cfg.headshape.headshape = headshape;
% cfg.headshape.interactive = 'no';
% cfg.headshape.icp = 'yes';
% cfg.coordsys = 'neuromag';
% mri_realigned = ft_volumerealign(cfg, mri_unknown);

%  
% save mri_realigned.mat mri_realigned


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

