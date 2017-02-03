%% Funciton
function [ft, tlock] = getSourceData_Function(subject, datapath, currentDirectory)
    disp(subject)
    cd(currentDirectory);
    megpath = strcat(datapath, 'task\sub-', subject, '\meg\task_raw.fif');
    
    %Checking if the file exists
    if (~(exist(megpath, 'file')))
        tlock = {}; %Indicate file was not found
        return;
    end
    
    %Code form PC_sourcemod_task
    hdr     = ft_read_header(megpath)
    raw_meg = ft_read_data(megpath);
    
    cfg            = [];
    cfg.continuous = 'yes';
    cfg.dataset    = megpath;
    cfg.channel    = {'MEG'};
%     cfg.channel    = {'megplanar'};
    cfg.detrend    = 'yes';
    cfg.bpfilter   = 'yes';
    cfg.bpfreq     = [1 150];
    megdata        = ft_preprocessing(cfg);
    
    % Triggers
    % Read in txt file
    filenames = {'AudOnly','AudVid300','AudVid600','AudVid1200','VidOnly'};
    onsetdir = strcat(datapath,'data\',subject,'\');
    
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
    
    triggeronsets={b,e,d,c,a};
    tlock = cell(1,5);
    ft=cell(1,5);
    for i = 1:5
        cfg=[];
        cfg.trl = [triggeronsets{i};triggeronsets{i}+1000;repmat(-100,1,length(triggeronsets{i}))]';
        ft{i}=ft_redefinetrial(cfg,megdata);
        
        ft{i}=ft_resampledata(struct('resamplefs',200),ft{i});
        
        
        cfg = [];
        tlock{i} = ft_timelockanalysis(cfg, ft{i});
    end



end