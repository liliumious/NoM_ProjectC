%% Replicating
function PC_makeHeadmodel_Function(subjectNumber, datapath, currentDirectory)
    %cd('C:\Users\Justin\Dropbox\University_Work\NetworkOfTheMind\NoM_ProjectC')
    cd(currentDirectory);
    
    %datapath = 'C:\Users\Justin\Desktop\MEGCanCam';
    mripath = strcat(datapath, '\MRI anatomy\sub-', subjectNumber, '\anat\sub-', subjectNumber ,'_T1w.nii');
    
    if (~(exist(mripath, 'file')))
        found = -1; %Indicate file was not found
        return;
    end

    mkdir(strcat('subjects\sub',subjectNumber,'\'));
    outputpath = strcat('subjects\sub',subjectNumber,'\');

    %Remember to change directories
    addpath C:\Users\Justin\Documents\Work\NetworkOfTheMind\fieldtrip %add fieldtrip
    ft_defaults

  



    %% Head Model
    mri_unknown = ft_read_mri(mripath)
    mri_unknown = ft_determine_coordsys(mri_unknown, 'interactive', 'yes');
    save([outputpath 'headmodel'],'mri_unknown')

    % % This automated method doesn't seem to produce a viable brain
    % cfg=[];
    % cfg.method='spm';
    % cfg.coordsys='spm';
    % target = ft_read_mri('MNI152_T1_1mm.img');
    % mri_spm = ft_volumerealign(cfg,mri_unknown,target)
    % save mri_spm mri_spm

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

    % Cannot plot due to coordsys mismatch between atlas and mri
    % aalpath = 'ROI_MNI_V4.nii'; 
    % aal = ft_read_atlas(aalpath);
    % cfg                    = [];
    % cfg.funparameter       = 'brain';
    % cfg.atlas              = aal;
    % cfg.roi           = 'Rectus_L';
    % segmentedmri.anatomy   = mri_neuro.anatomy;
    % ft_sourceplot(cfg, segmentedmri);
end
