
%Running makeHeadmodel & makeSourceModel for all subjects
%TODO: Deal with extracting files
datapath = 'C:\Users\Lily\Desktop\CamCan';
currentDirectory = 'C:\Users\Lily\Documents\NoM_ProjectC';

file = fopen(strcat(currentDirectory,'\subjectNames.txt'));
currentLine = fgets(file);

channelData = struct([]);

%Will return -1 when reaches end of file
%Grab channels 307:320
i = 1;
% currentLine = 'CC120065';
while ischar(currentLine)
    %Bypass the makeHeadModel prompts?
    raw_meg = PC_getMEGdata(currentLine, datapath, currentDirectory);
    if(~(raw_meg == -1))
        disp(i);
        %Inside the first channel is the struct;
        channelData(i).subject = currentLine;
        j = 1;
        channelData(i).channelNumbers = [];
        for chan = 307:339
            disp(chan);
            disp(j);
            channelData(i).channelNumbers(j,1) = chan;
            channelData(i).channelNumbers(j,2) = size(find(diff(raw_meg(chan,:))>2),2);
            j = j + 1;
        end
        i = i + 1;
    end
    currentLine = fgets(file);
end

fclose(file);