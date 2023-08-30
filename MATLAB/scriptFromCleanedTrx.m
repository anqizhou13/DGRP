%% This scripts extracts the action and amplitude of actions of all larvae from the trx.mat file, during the different time windows
clear all

%% Define the parameters

% !! Important: put all files in a "data" folder (with the "data" name
% only) contained in the main folder specified by 'adress' below
 adress='C:\Users\edetredern\Documents\Experiences\Comportement\20200407_trxattp2All\';
tfin=62;
% adress='C:\Users\edetredern\Documents\Experiences\Comportement\20200402_trxattp240\';
timewindows=[
    40 59 % ! time windows must not last for more than 59s
    60 61
    60 62
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

% set the actions you want to combine in a category, and change names
actionstocombine=struct;
actionstocombine(1).combination1=[1 2 5 8]; % escape 
actionstocombine(1).combination2=[3 4 9]; % startle
actionstocombine(2).combination1=[3 4 5 8]; % stophunchback
actionstocombine(2).combination2=[1 2 6 9]; % rest except stophunchback and small actions
numberofcombinations=length(actionstocombine);
namesactionstocombine=["escape","startle";"stophunchback","runcastbend"];

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

%% Get trx and names of conditions

% get all folders contained in the main folder in the directory; each folder = one condition
dossierppal=dir([adress 'data\']);
% get all the folders identities (one folder for each condition)
dirparcondition=find(vertcat(dossierppal.isdir));
dossiersparconditions=dossierppal(dirparcondition);
nombredeconditions=length(dirparcondition)-2;

% scan folders to get and concatenate data for each condition and get names of conditions
titres=[];
for condition=1:nombredeconditions
    titres=[titres; string(dossiersparconditions(condition+2).name)];
end

load([adress '\dataFiles\trx_withbackupandbend.mat'])

%% Extract the cumulative probability over time

cumulativeProbabilitiesOverTime=struct;
time0=timewindows(2,1);
for times=60.5:0.5:90
    fract=(times-floor(times))*10;
    windowname=['From60to' num2str(floor(times)) 'v' num2str(fract) 's'];
    windowtouse=[time0 times];
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        for action=1:length(states)
            actionname=states(action);
            [cumulativeProbabilitiesOverTime.(windowname).(conditionname).(actionname).proba, cumulativeProbabilitiesOverTime.(windowname).(conditionname).(actionname).probacontrol, cumulativeProbabilitiesOverTime.(windowname).(conditionname).(actionname).numberoflarvae, cumulativeProbabilitiesOverTime.(windowname).(conditionname).(actionname).numberoflarvaecontrol]=cumulativeFromTrx(TRX.(conditionname),windowtouse,action);
        end
    end
end

%% Calculate the cumulative probability right after the stimulus for actions that are triggered by the stim
% not the continuation of actions

cumulativeTriggeredActions=struct;
for condition=1:nombredeconditions
    conditionname=titres(condition);
    for action=1:length(states)
        actionname=states(action);
        [cumulativeTriggeredActions.(conditionname).(actionname).proba, cumulativeTriggeredActions.(conditionname).(actionname).numberoflarvae]=cumulativeAfterStimNotContinuing(TRX.(conditionname),action, tfin);
    end
end

xcat=categorical(regexprep(actionnames,'_',''));
datatoplot=NaN(length(xcat),nombredeconditions);
for action=1:length(states)
    actionname=states(action);
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        datatoplot(action,condition)=cumulativeTriggeredActions.(conditionname).(actionname).proba;
    end
end
figure
hold on
A=bar(xcat,datatoplot);
le=legend(regexprep(titres,'_',''));
% set(le,'Location','southeast');
ylabel('Probability ');
set(gca,'fontsize',24) ;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
title(['Cumulative probability of actions triggered by the stimulus, 60-' num2str(tfin) 's']);
filename=[adress 'cumulativeProbabilities\triggered60s' num2str(tfin) 's_cumulativeProba_barplot'];
saveas(gcf,[filename '.fig']);
saveas(gcf,[filename '.png']);

%% Extract the difference between simple cumulative probability and cumulative probability of actions triggered by the air puff

xcat=categorical(regexprep(actionnames,'_',''));
datatoplot=NaN(length(xcat),nombredeconditions);
for action=1:length(states)
    actionname=states(action);
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        windowname=['From60to' num2str(tfin) 'v0s'];
        datatoplot(action,condition)=cumulativeProbabilitiesOverTime.(windowname).(conditionname).(actionname).proba-cumulativeTriggeredActions.(conditionname).(actionname).proba;
    end
end
figure
hold on
A=bar(xcat,datatoplot);
le=legend(regexprep(titres,'_',''));
% set(le,'Location','southeast');
ylabel('Probability ');
set(gca,'fontsize',24) ;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
title(['Cumulative probability of actions not triggered by the stimulus, 60-' num2str(tfin) 's']);
filename=[adress 'cumulativeProbabilities\triggeredMINUS60s' num2str(tfin) 's_cumulativeProba_barplot'];
saveas(gcf,[filename '.fig']);
saveas(gcf,[filename '.png']);

%% Extract the amplitudes larva by larva, in concatenated trx.mat file

allAmplitudes=struct;
for condition=1:nombredeconditions
    conditionname=titres(condition);
    allAmplitudes.(conditionname)=extractAmplitudesFromTrx(TRX.(conditionname), timewindows);
end

filename=[adress 'dataFiles\allAmplitudes.mat'];
save(filename, 'allAmplitudes');

%% Plot amplitudes for hunches and head cast and bend for all conditions

fields = fieldnames(allAmplitudes);
for timewindow=1:numberofwindows
    windowname=['window' num2str(timewindow)];
    for action=[1 2 3 4 5 9] % crawl, head cast, stop, hunch, back, bend
        actionname=actionnames(action);
        for fieldtoscan=1:length(fields)
            fieldnametoscan=char(fields(fieldtoscan));
            matrixdata.amplitude.(fieldnametoscan)=[];
            matrixdata.time.(fieldnametoscan)=[];
            fieldslarva=fieldnames(allAmplitudes.(fieldnametoscan).(actionname).amplitude.(windowname));
            for fieldlarva=1:length(fieldslarva)
                larvaname=char(fieldslarva(fieldlarva));
                matrixdata.amplitude.(fieldnametoscan)=[matrixdata.amplitude.(fieldnametoscan); allAmplitudes.(fieldnametoscan).(actionname).amplitude.(windowname).(larvaname).actions];
                matrixdata.time.(fieldnametoscan)=[matrixdata.time.(fieldnametoscan); allAmplitudes.(fieldnametoscan).(actionname).time.(windowname).(larvaname).actions];
            end
        end
        
        parameters=["time";"amplitude"];
        for parametertoplot=1:length(parameters)
            parametername=parameters(parametertoplot);
            
            % histogram
            figure;
            hold on;
            mini=100;
            maxi=-100;
            for fieldtoscan=1:length(fields)
                fieldnametoscan=char(fields(fieldtoscan));
                datatoplot=matrixdata.(parametername).(fieldnametoscan);
                maxi=max(maxi, max(datatoplot));
                mini=min(mini, min(datatoplot));
            end
            maxi=ceil(maxi);
            mini=floor(mini);
            interval=(maxi-mini)/10;
            
            for fieldtoscan=1:length(fields)
                fieldnametoscan=char(fields(fieldtoscan));
                datatoplot=matrixdata.(parametername).(fieldnametoscan);
                histogram(datatoplot,mini-interval:interval:maxi+interval,'Normalization','probability','facealpha',.5);
            end
            title([windowname regexprep(char(actionname),'_','')]);
            XLab=[char(parametername) ' of ' regexprep(char(actionname),'_','')];
            xlabel(XLab);
            YLab='Workforce (%)';
            ylabel(YLab);
            titre=['window' num2str(timewindows(timewindow,1)) 'to' num2str(timewindows(timewindow,2))];
            title(titre);
            filename=[adress 'amplitudesAndTimesofActions\histogram' char(parametername) '_' char(actionname) '_' num2str(timewindows(timewindow,1)) '_' num2str(timewindows(timewindow,2))];
            saveas(gcf,[filename '.fig']);
            saveas(gcf,[filename '.png']);
            
            % means
            figure;
            hold on;
            Y=[];
            Ystd=[];
            for fieldtoscan=1:length(fields)
                fieldnametoscan=char(fields(fieldtoscan));
                Y=[Y nanmean(matrixdata.(parametername).(fieldnametoscan))];
                Ystd=[Ystd nanstd(matrixdata.(parametername).(fieldnametoscan))./sqrt(length(matrixdata.(parametername).(fieldnametoscan)))];
            end
            xcat=categorical(fields);
            fig2=bar(xcat,Y);
            hold on
            er = errorbar(xcat,Y,Ystd,Ystd);
            er.Color = [0 0 0];
            er.LineStyle = 'none';
            fig2.FaceColor = 'flat';
            for condition=1:length(fields)
                fig2.CData(condition,:) = couleursconditions(condition,:);
            end
            title([windowname regexprep(char(actionname),'_','')]);
            YLab=[char(parametername) ' of ' regexprep(char(actionname),'_','')];
            ylabel(XLab);
            titre=['window' num2str(timewindows(timewindow,1)) 'to' num2str(timewindows(timewindow,2))];
            title(titre);
            filename=[adress 'amplitudesAndTimesofActions\mean' char(parametername) '_' char(actionname) '_' num2str(timewindows(timewindow,1)) '_' num2str(timewindows(timewindow,2))];
            saveas(gcf,[filename '.fig']);
            saveas(gcf,[filename '.png']);
        end
    end
end