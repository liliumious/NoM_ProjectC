datapath = 'C:\Users\Lily\Dropbox\NetworkofMind';

megpath = [datapath '\MEG_Resting\sub-CC722891\meg\rest_raw.fif'];
outputpath = '.\sub891\';

hdr     = ft_read_header(megpath);
raw_meg = ft_read_data(megpath);
hdr

% Please run make_headmodel.m prior to this script
load([outputpath 'headmodel'])

%% Todo
% Add in the parcellation here

%% Construct source model
% Look into using inverse of mri_neuro.transform on sens with ft_transform
% sens
sens = ft_read_sens(megpath);
save([outputpath 'sourcemodel'],'sens')

cfg                 = [];
cfg.grad            = sens;
cfg.headmodel       = vol;
cfg.grid.resolution = 1;
cfg.grid.unit       = 'cm';
grid                = ft_prepare_sourcemodel(cfg);
save([outputpath 'sourcemodel'],'grid','-append')

%% Make a figure of head model and source model
figure
ft_plot_sens(sens, 'style', '*b');
hold on
ft_plot_vol(vol, 'edgecolor', 'none'); alpha 0.4;
ft_plot_mesh(grid.pos(grid.inside,:));
hold off
savefig([outputpath 'head_source'])

%% Compute the forward model for dipole locations

% A book keeping step prior to leadfield
[headmod, grad] = ft_prepare_vol_sens(vol, sens)

cfg                  = [];
cfg.grad             = grad;
cfg.vol              = headmod;   % volume conduction headmodel
cfg.grid             = grid;  % normalized grid positions
cfg.channel          = {'MEG'};
cfg.normalize        = 'yes'; % to remove depth bias (Q in eq. 27 of van Veen et al, 1997)
lf                   = ft_prepare_leadfield(cfg);

save([outputpath 'sourcemodel'],'lf','-append')

%% Preprocessing of MEG data
% WARNING will take a lot of memory
% Not sure why this is set up in 3 steps
% Please re: http://www.fieldtriptoolbox.org/tutorial/networkanalysis
load('.\sub891\sourcemodel')
load('.\sub891\headmodel')

cfg            = [];
cfg.continuous = 'yes';
cfg.dataset    = megpath;
cfg.channel    = {'MEG'};
megdata        = ft_preprocessing(cfg);

% Define 2s trials
% cfg         = [];
% cfg.length  = 2;
% cfg.overlap = 0.5;
% megdata     = ft_redefinetrial(cfg, megdata);

% Remove DC
cfg           = [];
cfg.continuous = 'yes';
cfg.channel    = {'MEG'};
cfg.demean    = 'yes';
cfg.bpfilter  = 'yes';
cfg.bpfreq    = [1 150]; % as per O'Neil paper
cfg.trials  = 1; % 1:560
megdata       = ft_preprocessing(cfg,megdata);


% Noise Covaraince estimation
cfg                  = [];
cfg.covariance       = 'yes';
cfg.covariancewindow = 'all'; 
cfg.vartrllength     = 2;
tlock                = ft_timelockanalysis(cfg, megdata);

% save([outputpath 'sourcemodel'], 'megdata', 'tlock','-v6')
% % Apparently can't have both -v6 and -append switches in one bracket?
% save([outputpath 'sourcemodel'],'sens', 'grid', 'lf', '-append')

%% Beam forming

cfg                  = [];
cfg.method           = 'lcmv';
cfg.grid             = lf; % leadfield, which has the grid information
cfg.headmodel        = vol; % volume conduction model (headmodel)
cfg.lcmv.keepfilter  = 'yes';
cfg.lcmv.fixedori    = 'yes'; % project on axis of most variance using SVD
source               = ft_sourceanalysis(cfg, tlock);


