% Matlab script to export to BIDS
targetFolder =  '../BIDS';

[~, ~, SubjInfo] = xlsread('Oddball_Subj_Info.xlsx','Step1_2');
files = dir('*.eeg')
pInfo = {'Group' 'ID' 'UPDRS'} ;
trialseq = { 'TrialOrder' 'Type' 'RT'} ;


for i = 1:length(files); 
data(i).file = files(i).name; 
data(i  ).session = [1];
data(i  ).run     = [1];
BehaviorFile = SubjInfo{i, 3};
load(['../Oddball_RawData/Behavior_Files/', BehaviorFile,'.mat'], 'trialseq');
pInfo{i+1,1} = SubjInfo{i, 1}; pInfo{i+1,2} = SubjInfo{i, 2}; pInfo{i+1,3} = SubjInfo{i, 3};



end




%% Code Files used to preprocess and import to BIDS
% -----------------------------------------------------|
codefiles = { fullfile(pwd, 'Step1_Oddball_PreProcess.m') fullfile(pwd, 'Step2_Oddball_PostProcess_V2.m') fullfile(pwd, 'Step3_Oddball_MakeMetafile.m') };

% general information for dataset_description.json file
% -----------------------------------------------------
generalInfo.Name = 'Cross-modal Oddbal Task';
generalInfo.ReferencesAndLinks = { 'No bibliographic reference other than the DOI for this dataset' };
generalInfo.BIDSVersion = 'v1.2.1';
generalInfo.License = 'CC0';
generalInfo.Authors = {'RachelCole' 'Nandakumar Narayanan' 'Jim Cavanagh' 'Arturo Espinoza' 'Arun Singh'};

% participant column description for participants.json file
% ---------------------------------------------------------
pInfoDesc.Group.Description     = 'Control or PD';
pInfoDesc.ID.Description = 'ID';
pInfoDesc.UPDRS.Description = 'UPDRS';
pInfoDesc.participant_id.Description = 'unique participant identifier';


% event column description for xxx-events.json file (only one such file)
% ----------------------------------------------------------------------
eInfo = {'onset'         'latency';
         'sample'        'latency';
         'value'         'type' }; % ADD HED HERE

eInfoDesc.onset.Description = 'Event onset';
eInfoDesc.onset.Units = 'second';

eInfoDesc.response_time.Description = 'Latency of button press after auditory stimulus';
eInfoDesc.response_time.Levels.Units = 'millisecond';

eInfoDesc.trial_type.Description = 'Type of event';
eInfoDesc.trial_type.Levels.stimulus = 'Auditory stimulus';
eInfoDesc.trial_type.Levels.responses = 'Behavioral response';

eInfoDesc.value.Description = 'Value of event';
eInfoDesc.value.Levels.response   = 'Response of the subject';
eInfoDesc.value.Levels.standard   = 'Standard at 500 hz for 60 ms';
eInfoDesc.value.Levels.ignore     = 'Ignore - not a real event';
eInfoDesc.value.Levels.oddball    = 'Oddball at 1000 hz for 60 ms';
eInfoDesc.value.Levels.noise      = 'White noise for 60 ms';

trialTypes = { 'S 1  = Viusal and sound cue';
'S 2  = Arrow: GO Cue';
'S 3  = Response----even late latency';};

% Content for README file
% Content for README file
% -----------------------
README = sprintf( [ 'NEEDS MODIFICATIONThis meditation experiment contains 24 subjects. Subjects were\n' ...
                    'NEEDS MODIFICATIONmeditating and were interupted about every 2 minutes to indicate\n' ...
                    'NEEDS MODIFICATIONtheir level of concentration and mind wandering. The scientific\n' ...
                    'NEEDS MODIFICATIONarticle (see Reference) contains all methodological details\n\n' ...
                    'NEEDS MODIFICATION' ]);

% Content for CHANGES file
% ------------------------
CHANGES = sprintf([ '' ]);

% Task information for xxxx-eeg.json file
% ---------------------------------------
tInfo.InstitutionAddress = 'Narayanan Lab / University of Iowa ';
tInfo.InstitutionName = '169 Newton Road';
tInfo.InstitutionalDepartmentName = 'Department of Neurology';
tInfo.PowerLineFrequency = 50;
tInfo.ManufacturersModelName = 'Brain Vision';

% call to the export function
% ---------------------------

bids_export(data, ...
    'targetdir', targetFolder, ...
    'taskName', 'Oddball',...
    'gInfo', generalInfo, ...
    'pInfo', pInfo, ...
    'pInfoDesc', pInfoDesc, ...
    'eInfo', eInfo, ...
    'eInfoDesc', eInfoDesc, ...
    'README', README, ...
    'CHANGES', CHANGES, ...
    'codefiles', codefiles, ...
    'trialtype', trialTypes, ...
    'checkresponse', 'condition 1', ...
    'tInfo', tInfo, ...
    'copydata', 0);


cwd = pwd; 
%%% Have to do this *after* all the files are made.  Boo. 
fprintf('Writing Behavior Files'); 
for i = 1:length(files); 
        cd(cwd); clear trialseq; 
    BehaviorFile = SubjInfo{i, 3};
    load(['../Oddball_RawData/Behavior_Files/', BehaviorFile,'.mat'], 'trialseq');
    if i<10; subVar = ['00' num2str(i)]; elseif i<100; subVar = ['0' num2Str(i)]; else subVar = num2str(i); end; 
    cd([targetFolder '/sub-' subVar]); 
    mkdir('beh'); cd('beh'); 

     
     t = table(trialseq(:,1), trialseq(:,2), trialseq(:,3), trialseq(:,4), trialseq(:,5), trialseq(:,6), trialseq(:,7), trialseq(:,8), trialseq(:,9),...
    'VariableNames', {'Trial', 'C1', 'C2', 'C3', 'C4', 'C5', 'RT', 'C6', 'C7'});

    writetable(t, ['sub-' subVar '_task-Oddball_beh.tsv'], 'delimiter', '\t', 'FileType', 'text');

    cd(cwd)
end


%                   Name: 'Cross-modal Oddbal Task'
%     ReferencesAndLinks: {'No bibliographic reference other than the DOI for this dataset'}
%            BIDSVersion: 'v1.2.1'
%                License: 'CC0'
%                Authors: {'RachelCole'  'Nandakumar Narayanan'  'Jim Cavanagh'  'Arturo Espinoza'  'Arun Singh'}
