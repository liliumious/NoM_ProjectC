megpath = './MEGCanCam/MEG Resting/sub-CC722891/meg/rest_raw.fif';
aalpath = 'ROI_MNI_V4.nii'; 
outputpath = './sub891/';

load([outputpath 'headmodel'])
%% Preprocessing of MEG data

cfg = [];
cfg.continuous = 'yes';
cfg.dataset    = megpath;
cfg.channel    = {'MEG'};
megdata = ft_preprocessing(cfg);

% Define 2s trials
cfg         = [];
cfg.length  = 2;
cfg.overlap = 0.5;
megdata        = ft_redefinetrial(cfg, megdata);

% Remove DC
cfg           = [];
cfg.demean    = 'yes';
cfg.bpfilter  = 'yes';
cfg.bpfreq    = [1 150]; % as per O'Neil paper
megdata       = ft_preprocessing(cfg, megdata);

% Noise Covaraince estimation
cfg = [];
cfg.covariance = 'yes';
cfg.covariancewindow = 'all'; 
cfg.vartrllength     = 2;
tlock = ft_timelockanalysis(cfg, megdata);


%% Construct source model
% Look into using inverse of mri_neuro.transform on sens with ft_transform
% sens
sens = ft_read_sens(megpath);
save sens sens

cfg                 = [];
cfg.grad            = sens;
cfg.headmodel       = vol;
cfg.grid.resolution = 1;
cfg.grid.unit       = 'cm';
grid                = ft_prepare_sourcemodel(cfg);
save grid grid

figure
ft_plot_sens(sens, 'style', '*b');
hold on
ft_plot_vol(vol, 'edgecolor', 'none'); alpha 0.4;
ft_plot_mesh(grid.pos(grid.inside,:));

% A book keeping step prior to leadfield
[headmod, grad] = ft_prepare_vol_sens(vol, sens)

%% Compute the forward model for dipole locations
cfg                  = [];
cfg.grad             = grad;
cfg.vol              = headmod;   % volume conduction headmodel
cfg.grid             = grid;  % normalized grid positions
cfg.channel          = {'MEG'};
cfg.normalize        = 'yes'; % to remove depth bias (Q in eq. 27 of van Veen et al, 1997)
lf                   = ft_prepare_leadfield(cfg);
save lf lf

%% Parcellation
aal = ft_read_atlas(aalpath);
cfg  = [];
cfg.method = 'mean';
cfg.parcellation = aalpath;
cfg.parameter = 'all'; 
parc = ft_sourceparcellate(cfg, lf, aal);


%% Beam forming
cfg                  = [];
cfg.method           = 'lcmv';
cfg.grid             = lf; % leadfield, which has the grid information
cfg.vol              = vol; % volume conduction model (headmodel)
cfg.keepfilter       = 'yes';
cfg.lcmv.fixedori    = 'yes'; % project on axis of most variance using SVD
source_avg           = ft_sourceanalysis(cfg, megdata);

aalpath = 'ROI_MNI_V4.nii'
aal = ft_read_atlas(aalpath);
cfg              = [];
dfg.atlas        = aal;
cfg.method       = 'ortho';
cfg.funcolormap  ='jet';
ft_sourceplot(cfg, source_avg)