%% SETUP
ccid = 'CC722891';
datapath = 'C:\Users\Lily\Dropbox\NetworkofMind\';
curdir = 'C:\Users\Lily\Documents\NoM_ProjectC\';
outpath = [curdir 'results\' ccid '\'];
mkdir(outpath)

%% Read in txt file
filenames = {'AudOnly','AudVid300','AudVid600','AudVid1200','VidOnly'};
onsetdir = [datapath 'notes\' ccid '\'];

onsets = {};
for i=1:5
    filename = [onsetdir 'onsets_' filenames{i} '.txt'];
    file = fopen(filename,'r');
    onsets{i} = fscanf(file,'%f');
    fclose(file);
end
clear file filename filenames i onsetdir

%% TASK DATA
megpath = [datapath 'MEG_task\sub-' ccid '\meg\task_raw.fif'];

hdr     = ft_read_header(megpath)
raw_meg = ft_read_data(megpath);

triggers = triggerplot(hdr,raw_meg,onsets,0);
% Saving trigger times
% 1. 'AudOnly'
% 2. 'AudVid300'
% 3. 'AudVid600'
% 4. 'AudVid1200'
% 5. 'VidOnly'
act_triggers = [];
for i=1:5
act_triggers = [act_triggers;...
            triggers{i}', repmat(i,length(triggers{i}),1);...
            ];
end
act_triggers = sortrows(act_triggers);
save([outpath 'triggers\active'],'act_triggers');

%% PASSIVE DATA
megpath = [datapath 'passive\sub-' ccid '\meg\passive_raw.fif'];

hdr     = ft_read_header(megpath)
raw_meg = ft_read_data(megpath);

% Visualise stim info
figure
hold on
trigger_chans = [307:310];
time = (1:hdr.nSamples)./1000;
for chan=trigger_chans
    plot(time,raw_meg(chan,:))
end
legend('show')
hold off

trig307 = find(diff(raw_meg(307,:))>2);
disp(['There are ' num2str(length(trig307)) ' triggers in channel 307']);
trig308 = find(diff(raw_meg(308,:))>2);
disp(['There are ' num2str(length(trig308)) ' triggers in channel 308']);
trig310 = find(diff(raw_meg(310,:))>2);
disp(['There are ' num2str(length(trig310)) ' triggers in channel 310']);

% 308 and 309 are the same

int78 = intersect(trig307,trig308);
disp(['There are ' num2str(length(int78)) ' intersections between chns 307 and 308']);
int80 = intersect(trig308,trig310);
disp(['There are ' num2str(length(int80)) ' intersections between chns 308 and 310']);
int70 = intersect(trig307,trig310);
disp(['There are ' num2str(length(int70)) ' intersections between chns 307 and 310']);

a = int70;
b = trig310(~ismember(trig310,a));
c = int78;
d = trig308(~ismember(trig308,c));

figure
title('Passive Task Trigger Onsets')
xlabel('Time in seconds')
ylim([-10 15])
hold on
plot(a./1000,1,'ro')
plot(b./1000,2,'y*')
plot(c./1000,3,'c*')
plot(d./1000,4,'m*')
hold off

triggers = zeros(120,2);
triggers = [
            a', repmat(13,length(a),1);...
            b', repmat(3,length(b),1);...
            c', repmat(12,length(c),1);...
            d', repmat(2,length(d),1);...
            ];
triggers = sortrows(triggers);
