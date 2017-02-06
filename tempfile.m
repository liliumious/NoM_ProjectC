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

%% 03/02/2017
cfg=[];
parcel = ft_sourceparcellate(cfg, source_int_mni, aal);

% read the atlas
aalpath = 'ROI_MNI_V4.nii';
aal = ft_read_atlas(aalpath);

load([outputpath 'sourcemodel'],'source')

% and call ft_sourceinterpolate:
cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter = 'tissue';
sourcemodel2 = ft_sourceinterpolate(cfg, aal, source{2});

sourcemodel2.tissue(isnan(sourcemodel2.tissue)) =0;
ids   = find(sourcemodel2.tissue);          %  all interpolate regions
id    = sourcemodel2.tissue(ids); %  all interpolate regions index
ROI   = aal.tissuelabel(id);
occid = find(strncmpi(ROI,'Occipital',9));  %  indice
OCC   = ROI(occid);  % label


%% 06/02/2017

load('hdm.mat')
subjectNumber = 'CC110033'; % temp, will automate over patients
datapath = 'C:\Users\Lily\Desktop\CamCan\';
currentDirectory = 'C:\Users\Lily\Documents\NoM_ProjectC\';
mripath =  strcat(datapath, '\anat\sub-', subjectNumber, '\anat\sub-', subjectNumber ,'_T1w.nii');

cfg = [];
cfg.grid.xgrid  = -20:1:20;
cfg.grid.ygrid  = -20:1:20;
cfg.grid.zgrid  = -20:1:20;
cfg.grid.unit   = 'cm';
cfg.grid.tight  = 'yes';
cfg.inwardshift = -1.5;
cfg.headmodel        = vol;
template_grid  = ft_prepare_sourcemodel(cfg);

aalpath = 'ROI_MNI_V4.nii';
atlas = ft_read_atlas(aalpath); 

atlas = ft_convert_units(atlas,'cm');
cfg = []
cfg.atlas = atlas;
cfg.roi = atlas.tissuelabel;
cfg.inputcoord = 'mni';
mask = ft_volumelookup(cfg,template_grid);

tmp                  = repmat(template_grid.inside,1,1);
tmp(tmp==1)          = 0;
tmp(mask)            = 1;

template_grid.inside = tmp;

mri_unknown = ft_read_mri(mripath)
mri_unknown = ft_determine_coordsys(mri_unknown, 'interactive', 'yes');

cfg          = [];
cfg.method   = 'interactive';
cfg.coordsys = 'spm';
mri_spm    = ft_volumerealign(cfg,mri_unknown)

cfg                = [];
cfg.grid.warpmni   = 'yes';
cfg.grid.template  = template_grid;
cfg.grid.nonlinear = 'yes';
cfg.mri            = mri_spm;
sourcemodel        = ft_prepare_sourcemodel(cfg);

figure
hold on
ft_plot_vol(hdm,  'facecolor', 'cortex', 'edgecolor', 'none');alpha 0.5; %camlight;
alpha 0.4           % make the surface transparent
ft_plot_mesh(sourcemodel.pos(sourcemodel.inside,:));
ft_plot_sens(sens, 'style', '*r');
hold off

[ft, tlock] = getSourceData_Function(subjectNumber, datapath, currentDirectory, 140);
dataica = ft{2};

cfg                 = [];
cfg.channel         = dataica.label;% ensure that rejected sensors are not present
cfg.grad            = dataica.grad;
cfg.vol             = hdm;
cfg.lcmv.reducerank = 2; % default for MEG is 2, for EEG is 3
cfg.grid = sourcemodel;
[grid] = ft_prepare_leadfield(cfg);

