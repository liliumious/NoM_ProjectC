%Averaging (timelock) over all patients
datapath = 'C:\Users\Lily\Desktop\CamCan\';
currentDirectory = 'C:\Users\Lily\Documents\NoM_ProjectC\';

file = fopen([currentDirectory '\subjectNames.txt']);
currentLine = fgets(file);

%We will store all our data in tlockAll
% tlock{i} will be the data for the ith stimulus
tlockAll = {};

%For all the stimuli

j = 1;
tlockCurrent = {};
%For all the patients we have
while ischar(currentLine)
    
    %Return -1 if patient does not exist (not downloaded)
    %Returns an cell array of the tlock for each stimulus
    currentData = getSourceData_Function(currentLine, datapath, currentDirectory);
    if(~isempty(currentData))
        %Every stimuli
        for i = 1:5
            %Store the tlock data in a cell array
            tlockAll{i,j} = currentData{i};
        end
        j = j + 1;
    end
    currentLine = fgets(file);
end


fclose(file);

save([currentDirectory 'results'],'tlockAll')