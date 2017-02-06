%% Replicating
function PC_makeHeadmodel_Function(subjectNumber, datapath, currentDirectory)
    %cd('C:\Users\Justin\Dropbox\University_Work\NetworkOfTheMind\NoM_ProjectC')
    cd(currentDirectory);
    
    %datapath = 'C:\Users\Justin\Desktop\MEGCanCam';
    mrizip = strcat(datapath, '\anat\sub-', subjectNumber, '\anat\sub-', subjectNumber ,'_T1w.nii.gz');
    gunzip(mrizip)
    mripath =  strcat(datapath, '\anat\sub-', subjectNumber, '\anat\sub-', subjectNumber ,'_T1w.nii');
    if (~(exist(mripath, 'file')))
        found = -1; %Indicate file was not found
        return;
    end

    mkdir(strcat('subjects\sub',subjectNumber,'\'));
    outputpath = strcat('subjects\sub',subjectNumber,'\');

    %% Head Model
    mri_unknown = ft_read_mri(mripath)
    mri_unknown = ft_determine_coordsys(mri_unknown, 'interactive', 'yes');
    save([outputpath 'headmodel'],'mri_unknown')

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

end
