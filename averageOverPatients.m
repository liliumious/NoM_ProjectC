%Averaging (timelock) over all patients
datapath = 'C:\Users\Lily\Desktop\CamCan\';
currentDirectory = 'C:\Users\Lily\Documents\NoM_ProjectC\';

file = fopen([currentDirectory '\subjectNames.txt']);
currentLine = fgets(file);

%We will store all our data in tlockAll
% tlock{i} will be the data for the ith stimulus
tlockAll = {};

%For all the stimuli
 for i = 1:5
     j = 1;
     tlockCurrent = {};
     %For all the patients we have
     while ischar(currentLine)
         
         %Return -1 if patient does not exist (not downloaded)
         subject = currentLine;
         currentData = getSourceData_Function(subject, datapath, currentDirectory, i);
         if(~isempty(currentData))
           
            %Store the tlock data in a cell array
            tlockCurrent{j} = currentData;
            j = j + 1;
         end
         currentLine = fgets(file);
     end
     tlockAll{i} = tlockCurrent;
 end
 

fclose(file);