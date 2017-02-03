%% Creating a grand average timelock over all patients

%Directories (Remember to change everytime)
datapath = 'C:\Users\Lily\Desktop\CamCan\';
currentDirectory = 'C:\Users\Lily\Documents\NoM_ProjectC\';

file = fopen([currentDirectory '\subjectNames.txt']);
currentLine = fgets(file);

%We will store all our data in tlockAll
% tlock{i} will be the data for the ith stimulus
% i = 
% 1 Aud Only
% 2 AudVid 300
% 3 AudVid 600
% 4 AudVid 1200
% 5 Vid Only
tlockAll = {};


j = 1;
%For all the patients we have downloaded
while ischar(currentLine)
    
    %Return empty struct if patient does not exist (not downloaded)
    %Returns an cell array of the tlock & before timelock for each stimulus
    [currentFT, currentTL] = getSourceData_Function(currentLine, datapath, currentDirectory);
    
    if(~isempty(currentData))
        %Every stimuli
        for i = 1:5
            %Store the tlock data in a cell array
            tlockAll{i,j} = currentTL{i};
            
            %Store the ft data
            ftAll{i,j} = currentFT{i};
        end
        j = j + 1;
    end
    currentLine = fgets(file);
end


fclose(file);

save([currentDirectory 'results'],'tlockAll')