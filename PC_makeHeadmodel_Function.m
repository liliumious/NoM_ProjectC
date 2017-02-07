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
    %Read in the MRI
    %Coordinate system is RAS
    mri_unknown = ft_read_mri(mripath)
    mri_unknown = ft_determine_coordsys(mri_unknown, 'interactive', 'yes');
    save([outputpath 'headmodel'],'mri_unknown')

    %Modify the MRI coordinate system to neuromag
    cfg          = [];
    cfg.method   = 'interactive';
    cfg.coordsys = 'neuromag';
    mri_neuro    = ft_volumerealign(cfg,mri_unknown)
    save([outputpath 'headmodel'],'mri_neuro','-append')

    % Note this brain has not been normalised! Todo before comparing to other
    % patients
    
    %Segment out the brain and ignore the rest of the head
    cfg           = [];
    cfg.output    = 'brain';
    segmentedmri  = ft_volumesegment(cfg, mri_neuro);
    save([outputpath 'headmodel'],'segmentedmri','-append')

    
    %Combining the slices from the MRI into a 3D volume
    cfg        = [];
    cfg.method = 'singleshell';
    vol        = ft_prepare_headmodel(cfg, segmentedmri);
    vol        = ft_convert_units(vol,'cm');
    save([outputpath 'headmodel'],'vol','-append')

end
