function [triggers,plot1,plot2] = triggerplot(hdr,raw_meg,onsets,option)
trig307 = find(diff(raw_meg(307,:))>2);
disp(['There are ' num2str(length(trig307)) ' triggers in channel 307']);
trig308 = find(diff(raw_meg(308,:))>2);
disp(['There are ' num2str(length(trig308)) ' triggers in channel 308']);
trig309 = find(diff(raw_meg(309,:))>2);
disp(['There are ' num2str(length(trig309)) ' triggers in channel 309']);

int78 = intersect(trig307,trig308);
disp(['There are ' num2str(length(int78)) ' intersections between chns 307 and 308']);
int89 = intersect(trig308,trig309);
disp(['There are ' num2str(length(int89)) ' intersections between chns 308 and 309']);
int79 = intersect(trig307,trig309);
disp(['There are ' num2str(length(int79)) ' intersections between chns 307 and 309']);


a = int79; % Vid Only
b = trig309(~ismember(trig309,a)); % Aud Only
c = int78; % AudVid 1200
d = trig308(~ismember(trig308,c)); % AudVid 600
e = trig307(~ismember(trig307,c)); 
e = e(~ismember(e,a)); % AudVid 300

triggers = {b,e,d,c,a};
% Visualise stim info - option 1s
if option==1
    figure
    hold on
    trigger_chans = [307:309];
    time = (1:hdr.nSamples)./1000;
    for chan=trigger_chans
        plot(time,raw_meg(chan,:))
    end
    legend('show')
    hold off
elseif option==2 % Compare and align - option 2
    figure
    subplot(1,2,1)
    title('Active Task Trigger Onsets'),xlabel('Time in seconds'),ylim([-10 15])
    hold on
    plot(triggers{1}./1000,1,'ro')
    plot(triggers{2}./1000,2,'yo')
    plot(triggers{3}./1000,3,'c*')
    plot(triggers{4}./1000,4,'m*')
    plot(triggers{5}./1000,5,'b*')
    hold off
    subplot(1,2,2)
    hold on
    for i=1:5
        plot(onsets{i},i,'b*')
    end
    hold off
else
    disp('No plots')
end
    
end