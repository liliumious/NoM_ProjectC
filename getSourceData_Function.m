%% Funciton
function tlock = getSourceData_Function(subject, datapath, currentDirectory, stimType)
    cd(currentDirectory);
    megpath = strcat(datapath, '\MEG_Task\sub-', subject, '\meg\task_raw.fif');
    outputpath = strcat('subjects\sub',subject,'\');
    
    %Checking if the file exists
    if (~(exist(megpath, 'file')))
        found = -1; %Indicate file was not found
        return;
    end
    
    %Code form PC_sourcemod_task
    hdr     = ft_read_header(megpath)
    raw_meg = ft_read_data(megpath);
    
    cfg            = [];
    cfg.continuous = 'yes';
    cfg.dataset    = megpath;
    cfg.channel    = {'megplanar'};
    cfg.detrend    = 'yes';
    cfg.bpfilter   = 'yes';
    cfg.bpfreq     = [1 150];
    megdata        = ft_preprocessing(cfg);
    
    % Triggers
    % Read in txt file
    filenames = {'AudOnly','AudVid300','AudVid600','AudVid1200','VidOnly'};
    onsetdir = [datapath 'notes\' subject '\'];
    
    onsets = {};
    for i=1:5
        filename = [onsetdir 'onsets_' filenames{i} '.txt'];
        file = fopen(filename,'r');
        onsets{i} = fscanf(file,'%f');
        fclose(file);
    end
    clear file filename filenames i onsetdir

    trig307 = find(diff(raw_meg(307,:))>2);
    trig308 = find(diff(raw_meg(308,:))>2);
    trig309 = find(diff(raw_meg(309,:))>2);

    int78 = intersect(trig307,trig308);
    int89 = intersect(trig308,trig309);
    int79 = intersect(trig307,trig309);
    
    a = int79; % Vid Only
    b = trig309(~ismember(trig309,a)); % Aud Only
    c = int78; % AudVid 1200
    d = trig308(~ismember(trig308,c)); % AudVid 600
    e = trig307(~ismember(trig307,c));
    e = e(~ismember(e,a)); % AudVid 300
    
    if(stimType == 1)
        triggeronsets = a;
    elseif (stimType == 2)
        triggeronsets = b;
    elseif (stimType == 3)
        triggeronsets = c;
    elseif (stimType == 4)
        triggeronsets = d;
    elseif (stimType == 5)
        triggeronsets = e;
    end

    cfg=[];
    cfg.trl = [triggeronsets;triggeronsets+1000;repmat(-100,1,length(triggeronsets))]';
    % cfg.trl = [triggeronsets;triggeronsets+100;repmat(100,1,length(triggeronsets))]';
    ft=ft_redefinetrial(cfg,megdata);

    ft=ft_resampledata(struct('resamplefs',200),ft);
    
    
    cfg                  = [];
    tlock                = ft_timelockanalysis(cfg, ft);
    
    %What does this command do?
    %avgcomb = ft_combineplanar([],tlock);




end