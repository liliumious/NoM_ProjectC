%% Gets the data out of the raw_meg file for one patient

function [ft, tlock] = getSourceData_Function(subject, datapath, currentDirectory)
    cd(currentDirectory);
    megpath = strcat(datapath, 'MEG task\sub-', subject, '\meg\task_raw.fif');
    
    %Checking if the file exists
    if (~(exist(megpath, 'file')))
        tlock = {}; %Indicate file was not found
        return;
    end
    
    %Read the meg data
    raw_meg = ft_read_data(megpath);
    
    cfg            = [];
    cfg.continuous = 'yes';
    cfg.dataset    = megpath;
    cfg.channel    = {'MEG'};
    cfg.detrend    = 'yes';
    cfg.bpfilter   = 'yes';
    cfg.bpfreq     = [1 150];
    megdata        = ft_preprocessing(cfg);
    
    cfg.channel    = {'EOG'};
    cfg.dataset = megpath;
    cfg.continuous = 'yes';
    eogdata = ft_preprocessing(cfg);
    
    % Triggers
    % Read in textfiles of when the triggers were activated
    filenames = {'AudOnly','AudVid300','AudVid600','AudVid1200','VidOnly'};
    onsetdir = strcat(datapath,'cc700-scored\MEG\release001\','data\',subject,'\');
    
    onsets = {};
    for i=1:5
        filename = [onsetdir 'onsets_' filenames{i} '.txt'];
        file = fopen(filename,'r');
        onsets{i} = fscanf(file,'%f');
        fclose(file);
    end
    clear file filename filenames i onsetdir
    
    
    %Calculate which trigger is which (using intersections)
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
    
    %For every stimuli store the data
    for i = 1:5
        
        %Taking 100 milliseconds before the stimulus and 1 second after
        cfg=[];
        cfg.trl = [triggeronsets{i};triggeronsets{i}+1000;repmat(-100,1,length(triggeronsets{i}))]';
        ft{i}=ft_redefinetrial(cfg,megdata);
        
        %Sampling the EOG data as well
        cfg=[];
        cfg.trl = [triggeronsets{i};triggeronsets{i}+1000;repmat(-100,1,length(triggeronsets{i}))]';
        eog = ft_redefinetrial(cfg,eogdata);
        
        
        %Resampling rate down to 200Hz
        ft{i}=ft_resampledata(struct('resamplefs',200),ft{i});
        eog=ft_resampledata(struct('resamplefs',200),eog);
        
        
        
        %Removing eyeblinks
        %perform the independent component analysis (i.e., decompose the data)
        cfg        = [];
        cfg.method = 'runica'; % this is the default and uses the implementation from EEGLAB
        
        comp = ft_componentanalysis(cfg, ft{i});
        
        %Concatanate the components and the EOG
        concatComp = [];
        concatEOG = [];
        for  trial = 1:size(triggeronsets{i},2)
            concatComp = [concatComp comp.trial{trial}];
            concatEOG = [concatEOG eog.trial{trial}];
        end
        
 
        %Want to check correlation between components
        corrAll = {};
        pValue = {};
     
        %Rows are sensors
        %Columns are left eye right eye
        [corrAll{trial}, pValue{trial}] = corr(concatComp',concatEOG');

        
      
        %Significant if it has a p value less than 0.05/306 (multiple
        %comparison)
        significant = {};
        significant = find(pValue{i} < (0.05/306));

        
        %Finding the union between the statistically significant components
        %from the first EOG sensor and the second EOG sensor
        sigEOG1 = significant(significant <= 306);
        sigEOG2 = significant(significant > 306);
        sig = union(sigEOG1', (sigEOG2 - 306)');
        
          
        %Removing components
        %remove the bad components and backproject the data
        cfg = [];
        cfg.component = sig; % to be removed component(s)
        ft{i} = ft_rejectcomponent(cfg, comp, ft{i});
        
        %Return the number of components we removed
        %TO DO add it to return values and change other functions;
        removed = size(sig,2);
        
         

 
        
        
        
            
        
%         % plot the components for visual inspection
%         figure
%         cfg = [];
%         cfg.component = [1:size(triggeronsets{i},2)];       % specify the component(s) that should be plotted
%         cfg.layout = 'neuromag306all.lay'; % specify the layout file that should be used for plotting
%         cfg.comment   = 'no';
%         ft_topoplotIC(cfg, comp)
%         
%         %Alternate plot
%         figure
%         cfg = [];
%         cfg.layout = 'neuromag306all.lay'; % specify the layout file that should be used for plotting
%         cfg.viewmode = 'component';
%         ft_databrowser(cfg, comp)

        
        %Running timelock analysis (averging the data)
        cfg = [];
        tlock{i} = ft_timelockanalysis(cfg, ft{i});
    end
end