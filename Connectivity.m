%% 06/02/2017 Connectivity
atlas = aal;
cfg = []; 
cfg.interpmethod = 'nearest'; 
cfg.parameter = 'tissue'; 
stat_atlas = ft_sourceinterpolate(cfg, atlas, stat);

x = find(ismember(atlas.tissuelabel,'Heschl_L'));
indxHGL = find(stat_atlas.tissue==x);

x=find(ismember(atlas.tissuelabel,'Heschl_R'));
indxHGR = find(stat_atlas.tissue==x); 
 
x=find(ismember(atlas.tissuelabel,'Cingulum_Mid_L'));
indxCML = find(stat_atlas.tissue==x); 

mri = mri_spm;
template_grid=ft_convert_units(template_grid,'mm');% ensure no unit mismatch
norm=ft_volumenormalise([],mri);
 
posCML=template_grid.pos(indxCML,:);% xyz positions in mni coordinates
posHGL=template_grid.pos(indxHGL,:);% xyz positions in mni coordinates
posHGR=template_grid.pos(indxHGR,:);% xyz positions in mni coordinates
 
posback=ft_warp_apply(norm.params,posCML,'sn2individual');
btiposCML= ft_warp_apply(pinv(norm.initial),posback);% xyz positions in individual coordinates
 
posback=ft_warp_apply(norm.params,posHGL,'sn2individual');
btiposHGL= ft_warp_apply(pinv(norm.initial),posback);% xyz positions in individual coordinates
 
posback=ft_warp_apply(norm.params,posHGR,'sn2individual');
btiposHGR= ft_warp_apply(pinv(norm.initial),posback);% xyz positions in individual coordinates

cfg=[];
cfg.vol=hdm;
cfg.channel=dataica.label;  
cfg.grid.pos=[btiposCML;btiposHGL;btiposHGR]./1000;% units of m
cfg.grad=dataica.grad;
sourcemodel_virt=ft_prepare_leadfield(cfg);

cfg = [];
cfg.channel=dataica.label;
cfg.covariance='yes';
cfg.covariancewindow=[0 1]; 
avg = ft_timelockanalysis(cfg,dataica);

cfg=[];
cfg.method='lcmv';
cfg.grid = sourcemodel_virt;
cfg.vol=hdm;
cfg.lcmv.keepfilter='yes';
cfg.lcmv.fixedori='yes';
cfg.lcmv.lamda='5%';
source=ft_sourceanalysis(cfg, avg);

% spatialfilter=cat(1,source.avg.filter{:});
spatialfilter=source.avg.filter{:};
virtsens=[];
for i=1:length(dataica.trial)
    virtsens.trial{i}=spatialfilter*dataica.trial{i};
 
end;
virtsens.time=dataica.time;
virtsens.fsample=dataica.fsample;
indx=[indxCML;indxHGL;indxHGR];
for i=1:length(virtsens.trial{1}(:,1))
    virtsens.label{i}=[num2str(i)];
end;

cfg = [];
cfg.channel = virtsens.label(1:16);% cingulum is prepresented by 16 locations
cfg.avgoverchan = 'yes';
virtsensCML = ft_selectdata(cfg,virtsens);
virtsensCML.label = {'CML'};
 
cfg.channel = virtsens.label(17:19); % left heschl by 3
virtsensHGL = ft_selectdata(cfg,virtsens);
virtsensHGL.label = {'HGL'};
 
cfg.channel = virtsens.label(20:21); % right heschl by 2
virtsensHGR = ft_selectdata(cfg,virtsens);
virtsensHGR.label = {'HGR'};

virtsensparcel=ft_appenddata([],virtsensCML,virtsensHGL,virtsensHGR);