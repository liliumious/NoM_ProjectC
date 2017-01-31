datapath = 'C:\Users\Lily\Dropbox\NetworkofMind';
megpath = ['C:\Users\Lily\Dropbox\NetworkofMind\MEG_task\sub-CC722891\meg\task_raw.fif'];

% megpath = [datapath '\MEG_task\sub-CC723395\meg\task_raw.fif'];
outputpath = '.\sub891\task\';

% Please run make_headmodel.m prior to this script
% load('.\sub891\headmodel')

hdr     = ft_read_header(megpath)
raw_meg = ft_read_data(megpath);


% % % Visualise stim info
figure
hold on
trigger_chans = [307:320];
time = (1:541000)./1000;
for chan=trigger_chans
    plot(time,raw_meg(chan,:))
end
legend('show')
hold off

% stimdur = 27001:29000;
% figure
% hold on
% trigger_chans = 1:306;
% time = (1:2000)./1000;
% for chan=trigger_chans
%     plot(time,raw_meg(chan,stimdur))
% end
% hold off

triggeronsets = find(diff(raw_meg(320,:))>2);

%309: 8 trigger
%308: 80
%307: 84
%320: 129

cfg            = [];
cfg.continuous = 'yes';
cfg.dataset    = megpath;
cfg.channel    = {'megplanar'};
cfg.detrend    = 'yes';
cfg.bpfilter   = 'yes';
cfg.bpfreq     = [1 150];
megdata        = ft_preprocessing(cfg);

% megdata.trial{1} = abs(megdata.trial{1});

cfg=[];
cfg.trl = [triggeronsets;triggeronsets+1000;repmat(-100,1,length(triggeronsets))]';
% cfg.trl = [triggeronsets;triggeronsets+100;repmat(100,1,length(triggeronsets))]';
ft=ft_redefinetrial(cfg,megdata);

ft=ft_resampledata(struct('resamplefs',100),ft);

cfg          = [];
cfg.method   = 'trial';
cfg.alim     = 2e-11; 
dummy        = ft_rejectvisual(cfg,ft);

cfg                  = [];
tlock                = ft_timelockanalysis(cfg, ft);

% cfg                 = [];
% cfg.method        = 'distance';
% cfg.neighbours      = ft_prepare_neighbours(cfg, tlock);
% cfg.planarmethod    = 'sincos';
% avgplanar        = ft_megplanar(cfg, tlock);
avgcomb = ft_combineplanar([],tlock);

figure(1);clf
ft_multiplotER([],tlock)


figure(1);clf
ft_topoplotER(struct('xlim',[.06 .1]),tlock)
figure(2);clf
ft_topoplotER(struct('xlim',[-.1 0]),tlock)

%% Todo
% Add in the parcellation here?

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
load('.\sub891\task\sourcemodel')
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
cfg.lcmv.projectnoise= 'yes';
source               = ft_sourceanalysis(cfg, tlock);
