%% TEMP DRAFT

currentDirectory = 'C:\Users\Lily\Documents\NoM_ProjectC\';

data = currentFT{2};

cfg = [];
cfg.channel= 'megplanar';	 
cfg.method = 'wavelet';
cfg.output = 'pow';
cfg.foi    = 1:2:30;	                
cfg.toi    = -0.5:0.05:1.5;	
freq = ft_freqanalysis(cfg, data)

cfg = [];    
cfg.showlabels   = 'yes';
cfg.layout = 'neuromag306all.lay';
figure
ft_multiplotTFR(cfg, freq)

load([currentDirectory 'results'],'tlockAll');
grandavg = ft_timelockgrandaverage([],tlockAll{5,:});
cfg = [];    
cfg.showlabels   = 'yes';
cfg.layout = 'neuromag306all.lay';
figure
ft_multiplotER(cfg, grandavg)