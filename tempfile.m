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


load('/template/headmodel/standard_singleshell');
cfg = [];
cfg.grid.xgrid  = -20:1:20;
cfg.grid.ygrid  = -20:1:20;
cfg.grid.zgrid  = -20:1:20;
cfg.grid.unit   = 'cm';
cfg.grid.tight  = 'yes';
cfg.inwardshift = -1.5;
cfg.headmodel   = vol;
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

megpath = strcat(datapath, 'task\sub-', subjectNumber, '\meg\task_raw.fif');
sens = ft_read_sens(megpath);
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

cfg = [];            
cfg.toilim = [-.18 -.05];
datapre = ft_redefinetrial(cfg, dataica); 
cfg.toilim = [.05 .18];
datapost = ft_redefinetrial(cfg, dataica); 

cfg = [];
cfg.covariance='yes';
cfg.covariancewindow = [-.3 .3];
avg = ft_timelockanalysis(cfg,dataica);
 
cfg = [];
cfg.covariance='yes';
avgpre = ft_timelockanalysis(cfg,datapre);
avgpst = ft_timelockanalysis(cfg,datapost);

cfg=[];
cfg.method='lcmv';
cfg.grid=grid;
cfg.vol=hdm;
cfg.lcmv.keepfilter='yes';
cfg.channel = dataica.label;
sourceavg=ft_sourceanalysis(cfg, avg);


%%

cfg=[];
cfg.method='lcmv';
cfg.grid=grid;
cfg.grid.filter=sourceavg.avg.filter;
cfg.vol=hdm;
sourcepreS1=ft_sourceanalysis(cfg, avgpre);
sourcepstS1=ft_sourceanalysis(cfg, avgpst);

cfg = [];
cfg.parameter = 'avg.pow';
cfg.operation = '((x1-x2)./x2)*100';
S1bl=ft_math(cfg,sourcepstS1,sourcepreS1);

template_mri = ft_read_mri('spm8T1.nii');
aalpath = 'ROI_MNI_V4.nii';
aal = ft_read_atlas(aalpath);

cfg              = [];
cfg.voxelcoord   = 'no';
cfg.parameter    = 'pow';
cfg.interpmethod = 'nearest';
source_int  = ft_sourceinterpolate(cfg, S1bl, template_mri);

cfg=[];
parcel = ft_sourceparcellate(cfg, source_int, aal);

dummy=atlas;
for i=1:length(parcel.pow)
      dummy.tissue(find(dummy.tissue==i))=parcel.pow(i);
end;

source_int.parcel=dummy.tissue;
source_int.coordsys = 'mni';
cfg=[];
cfg.method = 'ortho';
cfg.funparameter = 'parcel';
cfg.funcolormap    = 'jet';
cfg.renderer = 'zbuffer';
cfg.location = [-42 -20 6];
cfg.atlas = atlas;
cfg.funcolorlim = [-30 30];
ft_sourceplot(cfg,source_int);


cfg = [];
cfg.method         = 'surface';
cfg.funparameter   = 'parcel';
cfg.funcolorlim    = [-30 30];
cfg.funcolormap    = 'jet'; 
cfg.projmethod     = 'nearest'; 
cfg.surfinflated   = 'surface_inflated_both_caret.mat';
cfg.projthresh     = 0.95;
cfg.camlight       = 'no';
ft_sourceplot(cfg, source_int);
view ([-70 20 50])
light ('Position',[-70 20 50])
material dull

%%
cfg = [];
cfg.covariance='yes';
cfg.keeptrials = 'yes';
avgpre = ft_timelockanalysis(cfg,datapre);
avgpst = ft_timelockanalysis(cfg,datapost);

cfg=[];
cfg.method='lcmv';
cfg.grid=grid;
cfg.vol=hdm;
cfg.lcmv.keepfilter='yes';
cfg.channel = dataica.label;
sourceavg=ft_sourceanalysis(cfg, avg);
cfg=[];
cfg.method='lcmv';
cfg.grid=grid;
cfg.grid.filter=sourceavg.avg.filter;
cfg.rawtrial = 'yes';
cfg.vol=hdm;
sourcepreS1=ft_sourceanalysis(cfg, avgpre);
sourcepstS1=ft_sourceanalysis(cfg, avgpst);

cfg = [];
cfg.parameter    = 'pow';
cfg.dim          = grid.dim;
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.numrandomization = 1000;
 
ntrials = numel(sourcepreS1.trial);
design  = zeros(2,2*ntrials);
design(1,1:ntrials) = 1;
design(1,ntrials+1:2*ntrials) = 2;
design(2,1:ntrials) = [1:ntrials];
design(2,ntrials+1:2*ntrials) = [1:ntrials];
 
cfg.design   = design;
cfg.ivar     = 1;
cfg.uvar     = 2;
stat = ft_sourcestatistics(cfg,sourcepstS1,sourcepreS1);
stat.pos=template_grid.pos;% keep positions for plotting later

stat.inside=template_grid.inside;
cfg              = [];
cfg.voxelcoord   = 'no';
cfg.parameter    = 'stat';
cfg.interpmethod = 'nearest';
statint  = ft_sourceinterpolate(cfg, stat, template_mri);
cfg.parameter    = 'mask';
maskint  = ft_sourceinterpolate(cfg, stat, template_mri);
statint.mask = maskint.mask;


statint.coordsys = 'mni';
cfg               = [];
cfg.method        = 'ortho';
cfg.funparameter  = 'stat';
cfg.maskparameter = 'mask';
cfg.atlas         = atlas;
cfg.location = 'max';
cfg.funcolorlim   = [-5 5];
cfg.funcolormap = 'jet';
ft_sourceplot(cfg,statint);

%%
cfg=[];
parcel = ft_sourceparcellate(cfg, statint, aal);
parcelmask = ft_sourceparcellate(cfg, maskint, aal);
%% create dummy struct
dummy=aal;
dummymask = aal;
for i=1:length(parcel.stat)
      dummy.tissue(find(dummy.tissue==i))=parcel.stat(i);
      dummymask.tissue(find(dummymask.tissue==i))=parcelmask.mask(i);
end;
%% plot the result
statint.parcel=dummy.tissue;
statint.coordsys = 'mni';
statint.mask  = dummymask.tissue;
cfg=[];
cfg.method = 'slice';
cfg.funparameter = 'parcel';
cfg.funcolormap    = 'jet';
cfg.maskparameter = 'mask';
cfg.renderer = 'zbuffer';
cfg.funcolorlim   = [-5 5];
cfg.atlas = atlas;
ft_sourceplot(cfg,statint);
