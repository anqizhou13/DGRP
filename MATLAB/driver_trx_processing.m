%% This scripts extracts the probability, cumulative probability of actions,
% and transitions between actions
% of all larvae from the trx.mat file, during the different time windows

% Statistical test used for comparing cumulative proba (non corrected) :
% Chi2 test

% CHANGE : adresses, timewindows, couleursconditions, conditionstoplot,
% actionstoplot, couleursactions

% change the paths here to correspond to the files you are analyzing, following the format of /root folder/genotype/protocol/
adresses={
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_SS00739@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_SS00888@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_SS00918@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_55C05@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
%'/Volumes/TOSHIBA/t2/GMR_55C05@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/SS_TJ001_G2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
'/Volumes/TOSHIBA/t2/SS_TJ001_G2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/';
    };

for exp=1:length(adresses)
    
    clearvars -except adresses exp
    % Define the parameters
    
    % !! Important: put all files in a "data" folder (with the "data" name
    % only) contained in the main folder specified by 'adress' below
    adress=char(adresses(exp,:));
    timewindows=[
        15 30
        60 61
        60 62
        60 70 
        60 80
        60 90
        ];
    tfin=150; % change if you have a different duration of experiment
    numberofwindows=length(timewindows);
    actionnames=["crawl"
        "head_cast"
        "stop"
        "hunch"
        "back_up"
        "roll"
        "small_actions"
        "backup_sequence"
        "bend"
        ];
    states=["run";"cast";"stop";"hunch";"backup";"roll";"small_actions";
        "backup_sequence";
        "bend_static"
        ];
    
    
    couleursactions=[
        0    0    0 % crawl
        1    0    0 % head cast
        0    1    0 % stop
        0    0    1 % hunch
        0    1    1 % back-up
        1    1    0 % roll
        1    0    1 % small actions
        0    0.4470    0.7410 % backup sequences
        0.8500    0.3250    0.0980 % bend / static bend
        ];
    
 %% Concatenate trx for all experiments in each genotype
    TRX =concatenateTrx(adress);
    
    mkdir(adress, 'dataFiles');
    filename=[adress 'dataFiles'];
    save(filename, 'TRX'); % save concatenated trx file
   
    %% Reformat to include bend vs head cast
     
     actionLarva=struct;
   
         actionLarva=headVSbendFromTrx(TRX);
     
     % Add new fields with actions that take into account head cast vs bend
         for larva=1:length(TRX)
             larvaname=['larva' num2str(larva)];
             TRX(larva).global_state_large_state=actionLarva.(larvaname).action;
         end
    
    % Add new fields with actions over time for each action
    % write 1 if the action is performed, 0 if not
    
    for larva=1:length(TRX)
        larvaname=['larva' num2str(larva)];
        for action=1:length(states)
            actionname=states(action);
            indices=find(TRX(larva).global_state_large_state==action);
            numberstoadd=zeros(length(TRX(larva).global_state_large_state),1);
            numberstoadd(indices)=1;
            TRX(larva).(actionname)=numberstoadd;
        end
    end

%% Extract the probability of actions over time
   probabilities=struct;
 
       for action=1:length(states) % for each action (or state)
           actionname=states(action);
           probabilities.(actionname)=probabilityOfActionFromTrx(TRX,actionname,[timewindows(1,1) tfin]);
       end
   
   filename=[adress 'dataFiles/probabilitiesovertime.mat'];
   save(filename, 'probabilities'); % save probabilities of action over time
   
   %% Plot the probabilities over time
   
   % create new folder for the figures
   mkdir(adress, 'probabilitiesOverTime');
   
  
       fig=figure;
       hold on
       actionsplotovertime=[1 2 3 4 5 6 9];
       for action=actionsplotovertime % for each action except backup sequence & small actions
           actionname=states(action);
           X=probabilities.(actionname)(:,1);
           Y=probabilities.(actionname)(:,2);
           plot(X,Y,'color',couleursactions(action,:),'linewidth',2);
       end
       yl=ylim;
       le=legend(regexprep(actionnames(actionsplotovertime),'_',''));
       xlabel('Time (s)');
       ylabel('Probability of action');
       set(gca,'box','off')
       
       filename=[adress 'probabilitiesOverTime/00uncorr_probabilitiesovertime.fig'];
       saveas(gcf,filename);
       filename=[adress 'probabilitiesOverTime/00uncorr_probabilitiesovertime'];
       saveas(gcf,filename,'epsc')
       
   %% Extract the cumulative probabilities for the different time windows
       
       cumulativeProbabilities=struct;
       for timewindow=1:numberofwindows
           num1=regexprep(num2str(timewindows(timewindow,1)),'\.','p');
           num2=regexprep(num2str(timewindows(timewindow,2)),'\.','p');
           windowname=['window' num1 's_' num2 's'];
           windowtouse=timewindows(timewindow,:);
               for action=1:length(states)
                   actionname=states(action);
                   [cumulativeProbabilities.(windowname).(actionname).proba, cumulativeProbabilities.(windowname).(actionname).probacontrol, cumulativeProbabilities.(windowname).(actionname).numberoflarvae, cumulativeProbabilities.(windowname).(actionname).numberoflarvaecontrol]=cumulativeFromTrx(TRX,windowtouse,action);
               end
       end
       
       filename=[adress 'dataFiles/cumulativeProbabilities.mat'];
       save(filename, 'cumulativeProbabilities');

       %% Extract amplitudes of action
               allAmplitudes=struct;
       for timewindow = 1:numberofwindows
           allAmplitudes.(windowname)=extractAmplitudesFromTrx(TRX, timewindows);
       end

       filename=[adress 'dataFiles/amplitudes.mat'];
       save(filename, 'allAmplitudes');
    
    %% Extraction probability of transition from one action to another
    allTransitions=struct;
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        num1=regexprep(num2str(timestransitions(1,1)),'\.','p');
        num2=regexprep(num2str(timestransitions(1,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
            [allTransitions.notNormalized.(windowname), allTransitions.normalized.(windowname), meanNumberofTransitions.(windowname), nb_active.(windowname), nb_larvae_that_transition.(windowname), nb_transition_perlarvae.(windowname), first_transition.(windowname)]=transitionFromTrx(TRX, timestransitions);
    end
        allTransitionsForPlot=allTransitions;
   
    
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        num1=regexprep(num2str(timestransitions(1,1)),'\.','p');
        num2=regexprep(num2str(timestransitions(1,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
        categories=["notNormalized";"normalized"];
            for i=1:length(categories)
                namecat=categories(i);
                allTransitions.(namecat).(windowname)=array2table(allTransitions.(namecat).(windowname));
                for j=1:length(actionnames)
                    variablename=['Var' num2str(j)];
                    allTransitions.(namecat).(windowname).Properties.VariableNames{variablename} = char(actionnames(j));
                end
            end
    end
    
    filename=[adress 'dataFiles/allTransitions.mat'];
    save(filename, 'allTransitions');
    
    %% Plot transition matrix as heatmap
    
    mkdir(adress, 'transitions');
    
    colormap hot;
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        num1=regexprep(num2str(timestransitions(1,1)),'\.','p');
        num2=regexprep(num2str(timestransitions(1,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
 
            categories=["notNormalized";"normalized"];
            for i=1:length(categories)
                namecat=categories(i);
                datatoplot=round(allTransitionsForPlot.(namecat).(windowname),2);
                xcat=categorical(actionnames);
                h=figure;
                h=heatmap(xcat,xcat,datatoplot);
                if i==2
                    caxis([0 1]);
                end
                colormap hot;
                title(windowname);
                filename=[adress 'transitions\' windowname '_' char(namecat)];
                saveas(gcf,[filename '.fig']);
                saveas(gcf,[filename '.png']);
            end
    end
   
close all % close all of the figures for better memory performance
end
    
    
    
    
   