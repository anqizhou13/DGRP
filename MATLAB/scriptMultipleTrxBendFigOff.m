%% This scripts extracts the action and amplitude of actions of all larvae from the trx.mat file, during the different time windows
clear all

%% Define the parameters

% !! Important: put all files in a "data" folder (with the "data" name
% only) contained in the main folder specified by 'adress' below
adress='C:\Users\edetredern\Documents\Experiences\Comportement\20200329_trxattp240\';
timewindows=[
    40 59 % ! time windows must not last for more than 59s
    60 61
    60.5 62
    60 75
    60 90
    91 110 % recovery
    ];% time windows in seconds
numberofwindows=length(timewindows);
actionnames=["crawl"
    "head_cast"
    "stop"
    "hunch"
    "backup"
    "roll"
    "small_actions"
    "backup_sequence"
    "bend_static"
    ];
states=["run";"cast";"stop";"hunch";"back";"roll";"small_actions";"backup_sequence";"bend_static"];
actionsforamplitudes=[1 2 4 5];

% set the actions you want to combine in a category
actionstocombine=struct;
actionstocombine(1).combination1=[1 2 5 8]; % startle
actionstocombine(2).combination1=[3 4 9]; % escape
actionstocombine(1).combination2=[3 4 5 8]; % stophunchback
actionstocombine(2).combination2=[1 2 7 9]; % rest except stophunchback and small actions
numberofcombinations=length(actionstocombine);

couleurs=[
    0    0    0
    1    0    0
    0    1    0
    0    0    1
    0    1    1
    1    1    0
    1    0    1
    0    0.4470    0.7410 % color to show backup sequences
    0.8500    0.3250    0.0980 % head castin
    0.9290    0.6940    0.1250 % static bend
    ];

couleursconditions=[
    0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
    0.3010    0.7450    0.9330
    0.2422    0.1504    0.6603
    0.2504    0.1650    0.7076
    0.2578    0.1818    0.7511
    0.2647    0.1978    0.7952
    0.2706    0.2147    0.8364
    ];

%% Concatenate trx for all experiments in each condition

% get all folders contained in the main folder in the directory; each folder = one condition
dossierppal=dir([adress 'data\']);
% get all the folders identities (one folder for each condition)
dirparcondition=find(vertcat(dossierppal.isdir));
dossiersparconditions=dossierppal(dirparcondition);
nombredeconditions=length(dirparcondition)-2;

titres=[];
TRX=struct;

for condition=1:nombredeconditions
    titres=[titres; string(dossiersparconditions(condition+2).name)];
    conditionname=titres(condition);
    adressescan=[adress 'data\' dossiersparconditions(condition+2).name];
    TRX.(conditionname)=concatenateTrx(adressescan);
end

mkdir(adress, 'dataFiles');
filename=[adress 'dataFiles\trx_concatenated.mat'];
save(filename, 'TRX'); % save concatenated trx file

%% Reformat to include the whole backup sequence (even if bending/stop/other)

actionLarva=struct;
for condition=1:nombredeconditions
    conditionname=titres(condition);
    actionLarva.(conditionname)=backupSequenceFromTrx(TRX.(conditionname));
end

% Add new fields with actions that take into account backup
% sequences in actionLarva
for condition=1:nombredeconditions
    conditionname=titres(condition);
    for larva=1:length(TRX.(conditionname))
        larvaname=['larva' num2str(larva)];
        TRX.(conditionname)(larva).global_state_large_state_beforetreatment=TRX.(conditionname)(larva).global_state_large_state;
        TRX.(conditionname)(larva).global_state_large_state=actionLarva.(conditionname).(larvaname).action;
    end
end

%% Reformat to include bend vs head cast

actionLarva=struct;
for condition=1:nombredeconditions
    conditionname=titres(condition);
    actionLarva.(conditionname)=headVSbendFromTrx(TRX.(conditionname));
end

% Add new fields with actions that take into account backup
% sequences in actionLarva
for condition=1:nombredeconditions
    conditionname=titres(condition);
    for larva=1:length(TRX.(conditionname))
        larvaname=['larva' num2str(larva)];
        TRX.(conditionname)(larva).global_state_large_state=actionLarva.(conditionname).(larvaname).action;
    end
end

%% Add new fields with actions over time for each action
% write 1 if the action is performed, 0 if not

for condition=1:nombredeconditions
    conditionname=titres(condition);
    for larva=1:length(TRX.(conditionname))
        larvaname=['larva' num2str(larva)];
        for action=1:length(states)
            actionname=states(action);
            indices=find(TRX.(conditionname)(larva).global_state_large_state==action);
            numberstoadd=zeros(length(TRX.(conditionname)(larva).global_state_large_state),1);
            numberstoadd(indices)=1;
            TRX.(conditionname)(larva).(actionname)=numberstoadd;
        end
    end
end


filename=[adress 'dataFiles\trx_withbackupandbend.mat'];
save(filename, 'TRX');

% %% Plot the ethogram of the actions in all conditions
% 
% for condition=1:nombredeconditions % scan the different conditions
%     conditionname=titres(condition);
%     figuresaved=ethogramFromTrx(TRX.(conditionname));
%     
%     if figuresaved~=0
%         filename=[adress char(conditionname) '_ethogram.fig'];
%         saveas(figuresaved,filename); % save ethograms
%     end
% end

%% Extract the probability of actions over time

for action=1:length(states) % for each action (or state)
    actionname=states(action);
    for condition=1:nombredeconditions % scan the different conditions
        conditionname=titres(condition);
        probabilities.(conditionname).(actionname)=probabilityOfActionFromTrx(TRX.(conditionname),actionname);
    end
end

filename=[adress 'dataFiles\probabilitiesovertime.mat'];
save(filename, 'probabilities'); % save probabilities of action over time

%% Plot the probabilities over time

% create new folder for the figures
mkdir(adress, 'probabilitiesOverTime');

for condition=1:nombredeconditions % for the different conditions
    conditionname=titres(condition);
    fig=figure;
    hold on
    for action=1:length(states) % for each action (or state)
        actionname=states(action);
        X=probabilities.(conditionname).(actionname)(:,1);
        if action==8 % if it is the backup sequence, add the backup itself
            Y=probabilities.(conditionname).(actionname)(:,2)+probabilities.(conditionname).back(:,2);
        else
            Y=probabilities.(conditionname).(actionname)(:,2);
        end
        plot(X,Y,'color',couleurs(action,:),'linewidth',1);
    end
    title(conditionname);
    le=legend(regexprep(actionnames,'_',''));
    set(le,'Location','southeast');
    xlabel('Time (s)');
    ylabel('Probability of action');
    set(gca,'box','off')
    
    filename=[adress 'probabilitiesOverTime\' char(conditionname) '_probabilitiesovertime.fig'];
    saveas(gcf,filename);
    filename=[adress 'probabilitiesOverTime\' char(conditionname) '_probabilitiesovertime.png'];
    saveas(gcf,filename);
end

%% Plot the different actions for all conditions

for action=1:length(states) % for each action (or state)
    actionname=states(action);
    fig=figure;
    hold on
    for condition=1:nombredeconditions % for the different conditions
        conditionname=titres(condition);
        X=probabilities.(conditionname).(actionname)(:,1);
        if action==8 % if it is the backup sequence, add the backup itself
            Y=probabilities.(conditionname).(actionname)(:,2)+probabilities.(conditionname).back(:,2);
        else
            Y=probabilities.(conditionname).(actionname)(:,2);
        end
        plot(X,Y,'color',couleursconditions(condition,:),'linewidth',1);
    end
    title(regexprep(actionnames(action),'_',''));
    le=legend(regexprep(titres,'_',''));
    set(le,'Location','southeast');
    xlabel('Time (s)');
    ylabel('Probability of action');
    set(gca,'box','off')
    filename=[adress 'probabilitiesOverTime\' char(actionname) '_probabilitiesovertime.fig'];
    saveas(gcf,filename);
    filename=[adress 'probabilitiesOverTime\' char(actionname) '_probabilitiesovertime.png'];
    saveas(gcf,filename);
end

%% Calculate the corrected probabilities

for action=1:length(states) % for each action (or state)
    actionname=states(action);
    for condition=1:nombredeconditions % for the different conditions
        conditionname=titres(condition);
        if condition==1&&action==1
            beginindex=find(probabilities.(conditionname).(actionname)(:,1)==timewindows(1,1));
            endindex=find(probabilities.(conditionname).(actionname)(:,1)==timewindows(1,2));
        end
        probabilities_corrected.(conditionname).(actionname)(:,1)=probabilities.(conditionname).(actionname)(:,1);
        probabilities_corrected.(conditionname).(actionname)(:,2)=probabilities.(conditionname).(actionname)(:,2)-mean(probabilities.(conditionname).(actionname)(beginindex:endindex,2));
    end
end

filename=[adress 'dataFiles\probabilitiesovertime_corrected.mat'];
save(filename, 'probabilities_corrected'); % save corrected probabilities

%% Plot the different actions for all conditions corrected by the baseline

for action=1:length(states) % for each action (or state)
    actionname=states(action);
    fig=figure;
    hold on
    for condition=1:nombredeconditions % for the different conditions
        conditionname=titres(condition);
        X=probabilities_corrected.(conditionname).(actionname)(:,1);
        
        if action==8 % if it is the backup sequence, add the backup itself
            Y=probabilities_corrected.(conditionname).(actionname)(:,2)+probabilities_corrected.(conditionname).back(:,2);
        else
            Y=probabilities_corrected.(conditionname).(actionname)(:,2);
        end
        plot(X,Y,'color',couleursconditions(condition,:),'linewidth',1);
    end
    title(regexprep(actionnames(action),'_',''));
    le=legend(regexprep(titres,'_',''));;
    set(le,'Location','southeast');
    xlabel('Time (s)');
    ylabel('Probability of action');
    set(gca,'box','off')
    filename=[adress 'probabilitiesOverTime\' char(actionname) '_probabilitiesovertime_corrected.fig'];
    saveas(gcf,filename);
    filename=[adress 'probabilitiesOvertime\' char(actionname) '_probabilitiesovertime_corrected.png'];
    saveas(gcf,filename);
end

%% Calculate the mean probabilities for the time windows of interest

integration=struct;
for timewindow=1:numberofwindows
    windowname=['window' num2str(floor(timewindows(timewindow,1))) 's_' num2str(floor(timewindows(timewindow,2))) 's'];
    t1=timewindows(timewindow,1);
    t2=timewindows(timewindow,2);
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        for action=1:length(states)
            actionname=states(action);
            if condition==1&&action==1
                x=find(probabilities.(conditionname).(actionname)(:,1)>=t1&probabilities.(conditionname).(actionname)(:,1)<t2);
                x1=min(x);
                x2=max(x);
            end
            % integrate non corrected data
            integration.(actionname).(conditionname).(windowname).data=wmean(probabilities.(conditionname).(actionname)(x1:x2,2),probabilities.(conditionname).(actionname)(x1:x2,3));
            integration.(actionname).(conditionname).(windowname).larvesapprox=mean(probabilities.(conditionname).(actionname)(x1:x2,3));
            % integrate corrected data
            integration_corrected.(actionname).(conditionname).(windowname).data=wmean(probabilities_corrected.(conditionname).(actionname)(x1:x2,2),probabilities.(conditionname).(actionname)(x1:x2,3));
            integration_corrected.(actionname).(conditionname).(windowname).larvesapprox=mean(probabilities.(conditionname).(actionname)(x1:x2,3));
        end
    end
end

save([adress 'dataFiles\integration.mat'], 'integration');
save([adress 'dataFiles\integration_corrected.mat'], 'integration_corrected');

%% Plot probabilities time window by time window for non corrected data

% create new folder for the figures
mkdir(adress, 'meanProbabilities');

xcat=categorical(regexprep(actionnames,'_',''));
for windowtoplot=2:numberofwindows
    windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
    datatoplot=NaN(length(xcat),nombredeconditions);
    for action=1:length(states)
        actionname=states(action);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            datatoplot(action,condition)=integration.(actionname).(conditionname).(windowname).data;
        end
    end
    figure
    hold on
    A=bar(xcat,datatoplot);
    le=legend(regexprep(titres,'_',''));
    set(le,'Location','southeast');
    ylabel('Probability (%)');
    set(gca,'fontsize',24) ;
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    title(regexprep(windowname,'_',''));
    filename=[adress 'meanProbabilities\' windowname '_barplot'];
    saveas(gcf,[filename '.fig']);
    saveas(gcf,[filename '.png']);
end

%% Calculate p-values for differences in not corrected probabilities with chi2 test

if nombredeconditions>1
    pProbabilitiesForDifferentWindows=struct;
    for windowtoplot=2:numberofwindows
        windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
        for action=1:length(states)
            actionname=states(action);
            for condition=1:nombredeconditions-1
                conditionname=titres(condition);
                for condition2=condition+1:nombredeconditions
                    conditionname2=titres(condition2);
                    p1=integration.(actionname).(conditionname).(windowname).data;
                    N1=round(integration.(actionname).(conditionname).(windowname).larvesapprox); % nearest integer for number of larvae
                    p2=integration.(actionname).(conditionname2).(windowname).data;
                    N2=round(integration.(actionname).(conditionname2).(windowname).larvesapprox);
                    pProbabilitiesForDifferentWindows.(conditionname).(conditionname2).(actionname).(windowname)=chi2FromData(p1,p2,N1,N2);
                end
            end
        end
    end
    save([adress 'dataFiles\pProbabilitiesForDifferentWindows.mat'], 'pProbabilitiesForDifferentWindows');
end

%% Plot "startle" VS "escape" with not corrected data

xcat=categorical(["Startle";"Escape"]);
for windowtoplot=2:numberofwindows
    windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
    datatoplot=NaN(length(xcat),nombredeconditions);
    
    % startle
    action=1;
    actionname=char(xcat(action));
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        datatoplot(action,condition)=integration.stop.(conditionname).(windowname).data+integration.hunch.(conditionname).(windowname).data+integration.bend_static.(conditionname).(windowname).data;
    end
    
    % escape
    action=2;
    actionname=char(xcat(action));
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        datatoplot(action,condition)=integration.run.(conditionname).(windowname).data+integration.back.(conditionname).(windowname).data+integration.backup_sequence.(conditionname).(windowname).data+integration.cast.(conditionname).(windowname).data;
    end
    
    figure
    hold on
    A=bar(xcat,datatoplot);
    le=legend(regexprep(titres,'_',''));
    set(le,'Location','southeast');
    ylabel('Probability (%)');
    title(regexprep(windowname,'_',''));
    filename=[adress 'meanProbabilities\' windowname 'meanStartleVSescape'];
    saveas(gcf,[filename '.fig']);
    saveas(gcf,[filename '.png']); 
end

%% Plot probabilities time window by time window for corrected data

xcat=categorical(regexprep(states,'_',''));
for windowtoplot=2:numberofwindows
    windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
    datatoplot=NaN(length(xcat),nombredeconditions);
    for action=1:length(states)
        actionname=states(action);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            datatoplot(action,condition)=integration_corrected.(actionname).(conditionname).(windowname).data;
        end
    end
    figure
    hold on
    A=bar(xcat,datatoplot);
    le=legend(regexprep(titres,'_',''));
    set(le,'Location','southeast');
    ylabel('Probability (%)');
    set(gca,'fontsize',24) ;
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    title(regexprep(windowname,'_',''));
    filename=[adress 'meanProbabilities\' windowname '_corrected_barplot'];
    saveas(gcf,[filename '.fig']);
    saveas(gcf,[filename '.png']);
end

%% Plot "startle" VS "escape" with corrected data

xcat=categorical(["Startle";"Escape"]);
for windowtoplot=2:numberofwindows
    windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
    datatoplot=NaN(length(xcat),nombredeconditions);
    
    % startle
    action=1;
    actionname=char(xcat(action));
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        datatoplot(action,condition)=integration_corrected.stop.(conditionname).(windowname).data+integration_corrected.hunch.(conditionname).(windowname).data+integration_corrected.bend_static.(conditionname).(windowname).data;
    end
    
    % escape
    action=2;
    actionname=char(xcat(action));
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        datatoplot(action,condition)=integration_corrected.run.(conditionname).(windowname).data+integration_corrected.back.(conditionname).(windowname).data+integration_corrected.backup_sequence.(conditionname).(windowname).data+integration_corrected.cast.(conditionname).(windowname).data;
    end
    
    figure
    hold on
    A=bar(xcat,datatoplot);
    le=legend(regexprep(titres,'_',''));
    set(le,'Location','southeast');
    ylabel('Probability (%)');
    title(regexprep(windowname,'_',''));
    filename=[adress 'meanProbabilities\' windowname 'meanStartleVSescape_corrected'];
    saveas(gcf,[filename '.fig']);
    saveas(gcf,[filename '.png']); 
end

%% Extract the cumulative probabilities since begining of stimulus for the different ends of time windows

cumulativeProbabilities=struct;
for timewindow=1:numberofwindows
    windowname=['window' num2str(floor(timewindows(timewindow,1))) 's_' num2str(floor(timewindows(timewindow,2))) 's'];
    windowtouse=timewindows(timewindow,:);
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        for action=1:length(states)
            actionname=states(action);
            [cumulativeProbabilities.(windowname).(conditionname).(actionname).proba, cumulativeProbabilities.(windowname).(conditionname).(actionname).probacontrol, cumulativeProbabilities.(windowname).(conditionname).(actionname).numberoflarvae, cumulativeProbabilities.(windowname).(conditionname).(actionname).numberoflarvaecontrol]=cumulativeFromTrx(TRX.(conditionname),windowtouse,action);
        end
    end
end

filename=[adress 'dataFiles\cumulativeProbabilities.mat'];
save(filename, 'cumulativeProbabilities');

%% Extract the cumulative probabilities for startle and escape responses

for timewindow=1:numberofwindows
    windowname=['window' num2str(floor(timewindows(timewindow,1))) 's_' num2str(floor(timewindows(timewindow,2))) 's'];
    windowtouse=timewindows(timewindow,:);
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        [cumulativeProbabilities.(windowname).(conditionname).startle.proba, cumulativeProbabilities.(windowname).(conditionname).startle.probacontrol, cumulativeProbabilities.(windowname).(conditionname).startle.numberoflarvae, cumulativeProbabilities.(windowname).(conditionname).startle.numberoflarvaecontrol]=cumulativeStartleEscapeFromTrx(TRX.(conditionname),windowtouse,'startle');
        [cumulativeProbabilities.(windowname).(conditionname).escape.proba, cumulativeProbabilities.(windowname).(conditionname).escape.probacontrol, cumulativeProbabilities.(windowname).(conditionname).escape.numberoflarvae, cumulativeProbabilities.(windowname).(conditionname).escape.numberoflarvaecontrol]=cumulativeStartleEscapeFromTrx(TRX.(conditionname),windowtouse,'escape');
    end
end

filename=[adress 'dataFiles\cumulativeProbabilities.mat'];
save(filename, 'cumulativeProbabilities');

%% Calculate p-values for differences in cumulative probabilities

if nombredeconditions>1
    pProbabilitiesCumulative=struct;
    for windowtoplot=2:numberofwindows
        windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
        for action=1:length(states)
            actionname=states(action);
            for condition=1:nombredeconditions-1
                conditionname=titres(condition);
                for condition2=condition+1:nombredeconditions
                    conditionname2=titres(condition2);
                    % 1st condition
                    pA1=cumulativeProbabilities.(windowname).(conditionname).(actionname).proba;
                    NA1=round(cumulativeProbabilities.(windowname).(conditionname).(actionname).numberoflarvae); % nearest integer for number of larvae
                    nA1=pA1*NA1;
                    pB1=cumulativeProbabilities.(windowname).(conditionname).(actionname).probacontrol;
                    NB1=round(cumulativeProbabilities.(windowname).(conditionname).(actionname).numberoflarvaecontrol); % nearest integer for number of larvae
                    nB1=pB1*NB1;
                    % 2nd condition
                    pA2=cumulativeProbabilities.(windowname).(conditionname2).(actionname).proba;
                    NA2=round(cumulativeProbabilities.(windowname).(conditionname2).(actionname).numberoflarvae); % nearest integer for number of larvae
                    nA2=pA2*NA2;
                    pB2=cumulativeProbabilities.(windowname).(conditionname2).(actionname).probacontrol;
                    NB2=round(cumulativeProbabilities.(windowname).(conditionname2).(actionname).numberoflarvaecontrol); % nearest integer for number of larvae
                    nB2=pB2*NB2;
                    % test probability
                    pProbabilitiesCumulative.(conditionname).(conditionname2).(actionname).(windowname)=pvalueFromDataConvergence(nB2, NB2, nA2, NA2,nB1, NB1, nA1, NA1);
               
                    if action==1
                        % test for startle and escape
                        % startle
                        % 1st condition
                        pA1=cumulativeProbabilities.(windowname).(conditionname).startle.proba;
                        NA1=round(cumulativeProbabilities.(windowname).(conditionname).startle.numberoflarvae); % nearest integer for number of larvae
                        nA1=pA1*NA1;
                        pB1=cumulativeProbabilities.(windowname).(conditionname).startle.probacontrol;
                        NB1=round(cumulativeProbabilities.(windowname).(conditionname).startle.numberoflarvaecontrol); % nearest integer for number of larvae
                        nB1=pB1*NB1;
                        % 2nd condition
                        pA2=cumulativeProbabilities.(windowname).(conditionname2).startle.proba;
                        NA2=round(cumulativeProbabilities.(windowname).(conditionname2).startle.numberoflarvae); % nearest integer for number of larvae
                        nA2=pA2*NA2;
                        pB2=cumulativeProbabilities.(windowname).(conditionname2).startle.probacontrol;
                        NB2=round(cumulativeProbabilities.(windowname).(conditionname2).startle.numberoflarvaecontrol); % nearest integer for number of larvae
                        nB2=pB2*NB2;
                        % test probability
                        pProbabilitiesCumulative.(conditionname).(conditionname2).startle.(windowname)=pvalueFromDataConvergence(nB2, NB2, nA2, NA2,nB1, NB1, nA1, NA1);
                        
                        % escape
                        % 1st condition
                        pA1=cumulativeProbabilities.(windowname).(conditionname).escape.proba;
                        NA1=round(cumulativeProbabilities.(windowname).(conditionname).escape.numberoflarvae); % nearest integer for number of larvae
                        nA1=pA1*NA1;
                        pB1=cumulativeProbabilities.(windowname).(conditionname).escape.probacontrol;
                        NB1=round(cumulativeProbabilities.(windowname).(conditionname).escape.numberoflarvaecontrol); % nearest integer for number of larvae
                        nB1=pB1*NB1;
                        % 2nd condition
                        pA2=cumulativeProbabilities.(windowname).(conditionname2).escape.proba;
                        NA2=round(cumulativeProbabilities.(windowname).(conditionname2).escape.numberoflarvae); % nearest integer for number of larvae
                        nA2=pA2*NA2;
                        pB2=cumulativeProbabilities.(windowname).(conditionname2).escape.probacontrol;
                        NB2=round(cumulativeProbabilities.(windowname).(conditionname2).escape.numberoflarvaecontrol); % nearest integer for number of larvae
                        nB2=pB2*NB2;
                        % test probability
                        pProbabilitiesCumulative.(conditionname).(conditionname2).escape.(windowname)=pvalueFromDataConvergence(nB2, NB2, nA2, NA2,nB1, NB1, nA1, NA1);
                    end
                end
            end
        end
    end
    save([adress 'dataFiles\pProbabilitiesCumulative.mat'], 'pProbabilitiesCumulative');
end

%% Plot cumulative probabilities

% create new folder for the figures
mkdir(adress, 'cumulativeProbabilities');

xcat=categorical(regexprep(actionnames,'_',''));
for windowtoplot=2:numberofwindows
    windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
    datatoplot=NaN(length(xcat),nombredeconditions);
    for action=1:length(states)
        actionname=states(action);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            datatoplot(action,condition)=cumulativeProbabilities.(windowname).(conditionname).(actionname).proba;
        end
    end
    figure;
    hold on
    A=bar(xcat,datatoplot);
    le=legend(regexprep(titres,'_',''));
    ylabel('Cumulative probability');
    set(gca,'fontsize',24) ;
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    title(regexprep(windowname,'_',''));
    filename=[adress 'cumulativeProbabilities\' windowname '_cumulative_barplot'];
    saveas(gcf,[filename '.fig']);
    saveas(gcf,[filename '.png']);
end

%% Plot "startle" VS "escape" with cumulative probabilities

xcat=categorical(["Startle";"Escape"]);
for windowtoplot=2:numberofwindows
    windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
    datatoplot=NaN(length(xcat),nombredeconditions);
    
    % startle
    action=1;
    actionname=char(xcat(action));
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        datatoplot(action,condition)=cumulativeProbabilities.(windowname).(conditionname).startle.proba;
    end
    
    % escape
    action=2;
    actionname=char(xcat(action));
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        datatoplot(action,condition)=cumulativeProbabilities.(windowname).(conditionname).escape.proba;
    end
    
    figure
    hold on
    A=bar(xcat,datatoplot);
    le=legend(regexprep(titres,'_',''));
    set(le,'Location','southeast');
    ylabel('Probability (%)');
    title(regexprep(windowname,'_',''));
    filename=[adress 'cumulativeProbabilities\' windowname '_meanStartleVSescape'];
    saveas(gcf,[filename '.fig']);
    saveas(gcf,[filename '.png']);

end

%% Calculate the cumulative probability corrected by the baseline

cumulativeProbabilitiesCorrected=struct;
for timewindow=1:numberofwindows
    windowname=['window' num2str(floor(timewindows(timewindow,1))) 's_' num2str(floor(timewindows(timewindow,2))) 's'];
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        for action=1:length(states)
            actionname=states(action);
            cumulativeProbabilitiesCorrected.(windowname).(conditionname).(actionname).probacorrected=cumulativeProbabilities.(windowname).(conditionname).(actionname).proba-cumulativeProbabilities.(windowname).(conditionname).(actionname).probacontrol;
            cumulativeProbabilitiesCorrected.(windowname).(conditionname).(actionname).numberoflarvae=cumulativeProbabilities.(windowname).(conditionname).(actionname).numberoflarvae;
            cumulativeProbabilitiesCorrected.(windowname).(conditionname).(actionname).numberoflarvaecontrol=cumulativeProbabilities.(windowname).(conditionname).(actionname).numberoflarvaecontrol;
        end
        
        cumulativeProbabilitiesCorrected.(windowname).(conditionname).startle.probacorrected=cumulativeProbabilities.(windowname).(conditionname).startle.proba-cumulativeProbabilities.(windowname).(conditionname).startle.probacontrol;
        cumulativeProbabilitiesCorrected.(windowname).(conditionname).startle.numberoflarvae=cumulativeProbabilities.(windowname).(conditionname).startle.numberoflarvae;
        cumulativeProbabilitiesCorrected.(windowname).(conditionname).startle.numberoflarvaecontrol=cumulativeProbabilities.(windowname).(conditionname).startle.numberoflarvaecontrol;
        cumulativeProbabilitiesCorrected.(windowname).(conditionname).escape.probacorrected=cumulativeProbabilities.(windowname).(conditionname).escape.proba-cumulativeProbabilities.(windowname).(conditionname).escape.probacontrol;
        cumulativeProbabilitiesCorrected.(windowname).(conditionname).escape.numberoflarvae=cumulativeProbabilities.(windowname).(conditionname).escape.numberoflarvae;
        cumulativeProbabilitiesCorrected.(windowname).(conditionname).escape.numberoflarvaecontrol=cumulativeProbabilities.(windowname).(conditionname).escape.numberoflarvaecontrol;
    end
end

filename=[adress 'dataFiles\cumulativeProbabilitiesCorrected.mat'];
save(filename, 'cumulativeProbabilitiesCorrected');

%% Plot the cumulative probabilities corrected

xcat=categorical(regexprep(actionnames,'_',''));
for windowtoplot=2:numberofwindows
    windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
    datatoplot=NaN(length(xcat),nombredeconditions);
    for action=1:length(states)
        actionname=states(action);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            datatoplot(action,condition)=cumulativeProbabilitiesCorrected.(windowname).(conditionname).(actionname).probacorrected;
        end
    end
    figure
    hold on
    A=bar(xcat,datatoplot);
    le=legend(regexprep(titres,'_',''));
    set(le,'Location','southeast');
    ylabel('Cumulative probability corrected');
    set(gca,'fontsize',24) ;
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    title(regexprep(windowname,'_',''));
    filename=[adress 'cumulativeProbabilities\' windowname '_cumulative_barplot_corrected'];
    saveas(gcf,[filename '.fig']);
    saveas(gcf,[filename '.png']);
end

%% Plot "startle" VS "escape" with corrected cumulative probabilities

xcat=categorical(["Startle";"Escape"]);
for windowtoplot=2:numberofwindows
    windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
    datatoplot=NaN(length(xcat),nombredeconditions);
    
    % startle
    action=1;
    actionname=char(xcat(action));
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        datatoplot(action,condition)=cumulativeProbabilitiesCorrected.(windowname).(conditionname).startle.probacorrected;
    end
    
    % escape
    action=2;
    actionname=char(xcat(action));
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        datatoplot(action,condition)=cumulativeProbabilitiesCorrected.(windowname).(conditionname).escape.probacorrected;
    end
    
    figure
    hold on
    A=bar(xcat,datatoplot);
    le=legend(regexprep(titres,'_',''));
    set(le,'Location','southeast');
    ylabel('Probability (%)');
    title(regexprep(windowname,'_',''));
    filename=[adress 'cumulativeProbabilities\' windowname '_meanStartleVSescape_corrected'];
    saveas(gcf,[filename '.fig']);
    saveas(gcf,[filename '.png']);

end

%% Extract the amplitudes larva by larva, in concatenated trx.mat file

allAmplitudes=struct;
for condition=1:nombredeconditions
    conditionname=titres(condition);
    allAmplitudes.(conditionname)=extractAmplitudesFromTrx(TRX.(conditionname), timewindows);
end

filename=[adress 'dataFiles\amplitudes.mat'];
save(filename, 'allAmplitudes');

%% Reshape data to make statistical tests

reshapedAnova=struct; % will contain the data in order to calculate the ANOVA

larvawriteallconditions=1;
for condition=1:nombredeconditions
    conditionname=titres(condition);
    % Calculate the total number of larvae followed
    totalnumberoflarvae(condition)=length(TRX.(conditionname));
    for larvascan=1:totalnumberoflarvae(condition)
        larvanamescan=['larva' num2str(larvascan)];
        for timewindow=1:numberofwindows
            windowname=['window' num2str(timewindow)];
            % Reshape data for ANOVA
            reshapedAnova.(windowname).id(larvawriteallconditions,1)=condition;
            if isempty(allAmplitudes.(conditionname).crawl.speed.(windowname).(larvanamescan).total)==0
                reshapedAnova.(windowname).crawlspeed(larvawriteallconditions,1)=allAmplitudes.(conditionname).crawl.speed.(windowname).(larvanamescan).total;
            else
                reshapedAnova.(windowname).crawlspeed(larvawriteallconditions,1)=NaN;
            end
            if isempty(allAmplitudes.(conditionname).crawl.time.(windowname).(larvanamescan).total)==0
                reshapedAnova.(windowname).crawltime(larvawriteallconditions,1)=allAmplitudes.(conditionname).crawl.time.(windowname).(larvanamescan).total;
            else
                reshapedAnova.(windowname).crawltime(larvawriteallconditions,1)=NaN;
            end
            if isempty(allAmplitudes.(conditionname).bend.amplitude.(windowname).(larvanamescan).mean)==0
                reshapedAnova.(windowname).bendamplitude(larvawriteallconditions,1)=allAmplitudes.(conditionname).bend.amplitude.(windowname).(larvanamescan).mean;
            else
                reshapedAnova.(windowname).bendamplitude(larvawriteallconditions,1)=NaN;
            end
            if isempty(allAmplitudes.(conditionname).bend.time.(windowname).(larvanamescan).total)==0
                reshapedAnova.(windowname).bendtime(larvawriteallconditions,1)=allAmplitudes.(conditionname).bend.time.(windowname).(larvanamescan).total;
            else
                reshapedAnova.(windowname).bendtime(larvawriteallconditions,1)=NaN;
            end
            if isempty(allAmplitudes.(conditionname).hunch.amplitude.(windowname).(larvanamescan).mean)==0
                reshapedAnova.(windowname).hunchamplitude(larvawriteallconditions,1)=allAmplitudes.(conditionname).hunch.amplitude.(windowname).(larvanamescan).mean;
            else
                reshapedAnova.(windowname).hunchamplitude(larvawriteallconditions,1)=NaN;
            end
            if isempty(allAmplitudes.(conditionname).hunch.time.(windowname).(larvanamescan).total)==0
                reshapedAnova.(windowname).hunchtime(larvawriteallconditions,1)=allAmplitudes.(conditionname).hunch.time.(windowname).(larvanamescan).total;
            else
                reshapedAnova.(windowname).hunchtime(larvawriteallconditions,1)=NaN;
            end
            if isempty(allAmplitudes.(conditionname).back.speed.(windowname).(larvanamescan).total)==0
                reshapedAnova.(windowname).backspeed(larvawriteallconditions,1)=allAmplitudes.(conditionname).back.speed.(windowname).(larvanamescan).total;
            else
                reshapedAnova.(windowname).backspeed(larvawriteallconditions,1)=NaN;
            end
            if isempty(allAmplitudes.(conditionname).back.time.(windowname).(larvanamescan).total)==0
                reshapedAnova.(windowname).backtime(larvawriteallconditions,1)=allAmplitudes.(conditionname).back.time.(windowname).(larvanamescan).total;
            else
                reshapedAnova.(windowname).backtime(larvawriteallconditions,1)=NaN;
            end
        end
        larvawriteallconditions=larvawriteallconditions+1;
    end
end

%% Compare amplitude and normalized time data for significant differences

% Generate variables that will store the results of the test for amplitudes
pamplitudes=NaN(numberofwindows,length(actionsforamplitudes));
pairwisecomparisonsamplitudes=struct;
% and times
ptimes=NaN(numberofwindows,length(actionsforamplitudes));
pairwisecomparisonstimes=struct;

for timewindow=1:numberofwindows
    num=struct;
    windowname=['window' num2str(timewindow)];
    tableephemere=table2array(struct2table(reshapedAnova.(windowname)));
    taille=length(tableephemere);
    actioncount=1;
    for action=actionsforamplitudes
        actionname=actionnames(action);
        % test for amplitudes
        if ismember(sum(isnan(tableephemere(:,2*actioncount))),[taille-10:taille])==0 % must contain at least 10 actions
            [pamplitudes(timewindow,action),tbl,statstruct] = anova1(tableephemere(:,2*actioncount),tableephemere(:,1),'off');
            pairwisecomparisonsamplitudes.(windowname).(actionname) = multcompare(statstruct,'CType','bonferroni');%,'Display', 'off');
        end
        % test for times
        if ismember(sum(isnan(tableephemere(:,2*actioncount+1))),[taille-10:taille])==0
            [ptimes(timewindow,action),tbl,statstruct] = anova1(tableephemere(:,2*actioncount+1),tableephemere(:,1),'off');
            pairwisecomparisonstimes.(windowname).(actionname) = multcompare(statstruct,'CType','bonferroni');%,'Display', 'off');
            actioncount=actioncount+1;
        end
    end
end

filename=[adress 'dataFiles\pamplitudes.mat']; % store p-values for ANOVA of amplitudes
save(filename, 'pamplitudes'); % one line is a time window, one column is an action

filename=[adress 'dataFiles\pairwisecomparisonsamplitudes.mat'];
save(filename, 'pairwisecomparisonsamplitudes'); % look at last column for p values

filename=[adress 'dataFiles\ptimes.mat']; % store p-values for ANOVA of amplitudes
save(filename, 'ptimes'); % one line is a time window, one column is an action

filename=[adress 'dataFiles\pairwisecomparisonstimes.mat'];
save(filename, 'pairwisecomparisonstimes'); % look at last column for p values

%% Calculate the mean and sem of the different parameters
% mean times normalized contains the mean time performing the action by the
% larvae that perform indeed the action during the time window, normalized
% by the length of that time window (in order to be able to compare time
% windows together)

meansandsem=struct;

for condition=1:nombredeconditions
    conditionname=titres(condition);
    
    meanamplitudes=NaN(numberofwindows,length(actionsforamplitudes)); % stores weighted means
    semamplitudes=NaN(numberofwindows,length(actionsforamplitudes)); % stores non weighted sem
    meantimes=NaN(numberofwindows,length(actionsforamplitudes)); % stores time doing the action
    semtimes=NaN(numberofwindows,length(actionsforamplitudes)); % stores sem
    meannormalizedtimes=NaN(numberofwindows,length(actionsforamplitudes)); % stores time doing the action normalized by the length of the time window
    semnormalizedtimes=NaN(numberofwindows,length(actionsforamplitudes)); % stores normalized sem
    
    for timewindow=1:numberofwindows
        windowname=['window' num2str(timewindow)];
        for action=actionsforamplitudes
            values=NaN(totalnumberoflarvae(condition),1);
            weights=NaN(totalnumberoflarvae(condition),1);
            for numberlarva=1:totalnumberoflarvae(condition)
                larvaname=['larva' num2str(numberlarva)];
                if action==1 % run
                    if isempty(allAmplitudes.(conditionname).crawl.time.(windowname).(larvaname).total)==0 % if the larva is tracked during the window and performs the action
                        values(numberlarva)=allAmplitudes.(conditionname).crawl.speed.(windowname).(larvaname).total;
                        weights(numberlarva)=allAmplitudes.(conditionname).crawl.time.(windowname).(larvaname).total;
                    end
                elseif action == 2 % bend
                    if isempty(allAmplitudes.(conditionname).bend.time.(windowname).(larvaname).total)==0 % if the larva is tracked during the window and performs the action
                        values(numberlarva)=allAmplitudes.(conditionname).bend.amplitude.(windowname).(larvaname).mean;
                        weights(numberlarva)=allAmplitudes.(conditionname).bend.time.(windowname).(larvaname).total;
                    end
                elseif action == 4 % hunch
                    if isempty(allAmplitudes.(conditionname).hunch.time.(windowname).(larvaname).total)==0 % if the larva is tracked during the window and performs the action
                        values(numberlarva)=allAmplitudes.(conditionname).hunch.amplitude.(windowname).(larvaname).mean;
                        weights(numberlarva)=allAmplitudes.(conditionname).hunch.time.(windowname).(larvaname).total;
                        if isnan(values(numberlarva))==1 || isnan(weights(numberlarva))==1
                            values(numberlarva)=NaN;
                            weights(numberlarva)=NaN;
                        end
                    end
                elseif action==5 % backup
                    if isempty(allAmplitudes.(conditionname).back.time.(windowname).(larvaname).total)==0 % if the larva is tracked during the window and performs the action
                        values(numberlarva)=allAmplitudes.(conditionname).back.speed.(windowname).(larvaname).total;
                        weights(numberlarva)=allAmplitudes.(conditionname).back.time.(windowname).(larvaname).total;
                    end
                end
                
            end
            if sum(~isnan(weights))~=0 && sum(~isnan(values))~=0
                meanamplitudes(timewindow,action)=wmean(values(~isnan(values)),weights(~isnan(weights)));
                semamplitudes(timewindow,action)=nanstd(values(~isnan(values)))/sqrt(sum(~isnan(weights)));
                meantimes(timewindow,action)=nanmean(weights);
                semtimes(timewindow,action)=nanstd(weights)/sqrt(sum(~isnan(weights)));
                meannormalizedtimes(timewindow,action)=meantimes(timewindow,action)/(timewindows(timewindow,2)-timewindows(timewindow,1));
                semnormalizedtimes(timewindow,action)=semtimes(timewindow,action)/(timewindows(timewindow,2)-timewindows(timewindow,1));
            end
        end
    end
    meansandsem.(conditionname).meanamplitudes=meanamplitudes;
    meansandsem.(conditionname).semamplitudes=semamplitudes;
    meansandsem.(conditionname).meantimes=meantimes;
    meansandsem.(conditionname).semtimes=semtimes;
    meansandsem.(conditionname).meannormalizedtimes=meannormalizedtimes;
    meansandsem.(conditionname).semnormalizedtimes=semnormalizedtimes;
end

filename=[adress 'dataFiles\meansandsem.mat']; % store p-values for ANOVA of amplitudes
save(filename, 'meansandsem'); % one line is a time window, one column is an action

%% Plot amplitudes and times

xcat=categorical(titres);

% create new folder for the figures
mkdir(adress, 'amplitudesAndTimesofActions');

% Amplitudes
for timewindow=1:numberofwindows
    windowname=['window' num2str(timewindow)];
    Y=[];
    Ysem=[];
    for action=actionsforamplitudes
        actionname=actionnames(action);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            Y(condition)=meansandsem.(conditionname).meanamplitudes(timewindow,action);
            Ysem(condition)=meansandsem.(conditionname).semamplitudes(timewindow,action);
        end
        Y=Y.';
        Ysem=Ysem.';
        figure;
        hold on
        fig2=bar(xcat,Y);
        er = errorbar(xcat,Y,Ysem,Ysem);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:nombredeconditions
            fig2.CData(condition,:) = couleursconditions(condition,:);
        end
        YLab=['amplitude of ' regexprep(char(actionname),'_','')];
        ylabel(YLab);
        set(gca,'box','off')
        titre=['window' num2str(timewindows(timewindow,1)) 'to' num2str(timewindows(timewindow,2))];
        title(titre);
        filename=[adress 'amplitudesAndTimesofActions\amplitude_' char(actionname) '_' num2str(timewindows(timewindow,1)) '_' num2str(timewindows(timewindow,2))];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
    end
end

% Time spent doing the action normalized to time window
for timewindow=1:numberofwindows
    windowname=['window' num2str(timewindow)];
    for action=actionsforamplitudes
        actionname=actionnames(action);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            Y(condition)=meansandsem.(conditionname).meannormalizedtimes(timewindow,action);
            Ysem(condition)=meansandsem.(conditionname).semnormalizedtimes(timewindow,action);
        end
        Y=Y.';
        Ysem=Ysem.';
        figure;
        hold on
        fig2=bar(xcat,Y);
        er = errorbar(xcat,Y,Ysem,Ysem);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        fig2.FaceColor = 'flat';
        for condition=1:nombredeconditions
            fig2.CData(condition,:) = couleursconditions(condition,:);
        end
        YLab=['normalized time of ' regexprep(char(actionname),'_','')];
        ylabel(YLab);
        set(gca,'box','off')
        titre=['window' num2str(timewindows(timewindow,1)) 'to' num2str(timewindows(timewindow,2))];
        title(titre);
        filename=[adress 'amplitudesAndTimesofActions\timenormalized_' char(actionname) '_' num2str(timewindows(timewindow,1)) '_' num2str(timewindows(timewindow,2))];
        saveas(gcf,[filename '.fig']);
        saveas(gcf,[filename '.png']);
    end
end
