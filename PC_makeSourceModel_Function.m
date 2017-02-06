function [source] = PC_makeSourceModel_Function(subjectNumber, datapath, currentDirectory)
    cd(currentDirectory);
    megpath = strcat(datapath, '\task\sub-', subjectNumber, '\meg\task_raw.fif');
    outputpath = strcat('subjects\sub',subjectNumber,'\');
    %Checking if the files exists
    if (~(exist(megpath, 'file')))
        disp('File not found') %Indicate file was not found
        return;
    end  
    % Load headmodel and sensor data prior to running
    load([outputpath 'headmodel'],'vol')
    load([outputpath 'sensordata'],'tlock')

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
    %Commented out for the time as scaling up dont need to plot just need
    %data
    figure
    ft_plot_sens(sens, 'style', '*b');
    hold on
    ft_plot_vol(vol, 'edgecolor', 'none'); alpha 0.4;
    ft_plot_mesh(grid.pos(grid.inside,:));
    hold off

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


    %% Beam forming for each of the 5 conditions
    source=cell(1,5);
    for i=1:5
        cfg                  = [];
        cfg.method           = 'lcmv';
        cfg.grid             = lf; % leadfield, which has the grid information
        cfg.headmodel        = headmod; % volume conduction model (headmodel)
        cfg.lcmv.keepfilter  = 'yes';
        cfg.lcmv.fixedori    = 'yes'; % project on axis of most variance using SVD
        source{i}            = ft_sourceanalysis(cfg, tlock{i});
    end
    save([outputpath 'sourcemodel'],'source','-append')
end

