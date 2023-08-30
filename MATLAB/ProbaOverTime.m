%% This script makes plots from behaviour_probability.mat, where are stored probabilities over time

% First section: change parameters entered.
% Second section: extract probabilities and number of larvae for all
% conditions from behaviour_probability.mat.
% Third section: calculate and plot not corrected data, with one graph for
% each action, and all conditions on each graph.
% Fourth section: calculate and plot corrected data (by the first time window), with one graph for
% each action, and all conditions on each graph.
% Fifth section: calculates the mean probability of action over the
% different time windows defined by integrating the probability over this
% time period. NB: not considering the variable number of larvae!
% Sixth section: plot these probabilities as bar plots.
% Seventh and eigth: same for corrected data.

%% Change if needed the parameters entered

% the time windows over which the probabilities of action will be
% calculated (in seconds)
timewindows=[30 59 % NB : this first time window defines the baseline; do not calculate it below 30s because behaviour_probability.mat does not contain time points before
    60 61
    60 62
    60 70
    60 80
    60 90
    ]; % t2 data
% timewindows=[35 44 % NB : this first time window defines the baseline; do not calculate it below 30s because behaviour_probability.mat does not contain time points before
%     45 46
%     45.5 47
%     45 55
%     45 65;45 75
%     ]; % t5 data

numberofwindows=length(timewindows);


% the path for finding the main folder, that contains several subfolders;
% in each subfolder are present one or several hit_analysis folders (if
% several hit_analysis folders, the probabilities of action will be put together for all
% the different folders)
adresse='C:\Users\edetredern\Documents\Experiences\Comportement\20200416_Janelia_decision\Attp2\Mepd90\'; % do not forget last \

% the colors that will be used to plot the different conditions if needed
couleurs=[
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
    0.2751    0.2342    0.8710
    0.2783    0.2559    0.8991
    0.2803    0.2782    0.9221
    0.2813    0.3006    0.9414
    0.2810    0.3228    0.9579
    0.2795    0.3447    0.9717
    0.2760    0.3667    0.9829
    0.2699    0.3892    0.9906
    0.2602    0.4123    0.9952
    0.2440    0.4358    0.9988
    0.2206    0.4603    0.9973
    0.1963    0.4847    0.9892
    0.1834    0.5074    0.9798
    0.1786    0.5289    0.9682
    0.1764    0.5499    0.9520
    0.1687    0.5703    0.9359
    0.1540    0.5902    0.9218
    0.1460    0.6091    0.9079
    0.1380    0.6276    0.8973
    0.1248    0.6459    0.8883
    0.1113    0.6635    0.8763
    0.0952    0.6798    0.8598
    0.0689    0.6948    0.8394
    0.0297    0.7082    0.8163
    0.0036    0.7203    0.7917
    0.0067    0.7312    0.7660
    0.0433    0.7411    0.7394
    0.0964    0.7500    0.7120
    0.1408    0.7584    0.6842
    0.1717    0.7670    0.6554
    0.1938    0.7758    0.6251
    0.2161    0.7843    0.5923
    0.2470    0.7918    0.5567
    0.2906    0.7973    0.5188
    0.3406    0.8008    0.4789
    0.3909    0.8029    0.4354
    0.4456    0.8024    0.3909
    0.5044    0.7993    0.3480
    0.5616    0.7942    0.3045
    0.6174    0.7876    0.2612
    0.6720    0.7793    0.2227
    0.7242    0.7698    0.1910
    0.7738    0.7598    0.1646
    0.8203    0.7498    0.1535
    0.8634    0.7406    0.1596
    0.9035    0.7330    0.1774
    0.9393    0.7288    0.2100
    0.9728    0.7298    0.2394
    0.9956    0.7434    0.2371
    0.9970    0.7659    0.2199
    0.9952    0.7893    0.2028
    0.9892    0.8136    0.1885
    0.9786    0.8386    0.1766
    0.9676    0.8639    0.1643
    0.9610    0.8890    0.1537
    0.9597    0.9135    0.1423
    0.9628    0.9373    0.1265
    0.9691    0.9606    0.1064
    0.9769    0.9839    0.0805
    ];

% the colors that will be used to plot the different actions if needed
couleursactions=[
    0    0.4470    0.7410 %blue
    0.3010    0.7450    0.9330 %fair blue
    0.8  0.2 0%dark orange
    0.8500    0.3250    0.0980%fair orange
    0.8  0.6 0%dark mustard
    0.9290    0.6940    0.1250%fair mustard
    ];

% the actions performed by the larvae % NB. Also included in combinepipeline
actionsperformed=["run"; "cast"; "stop"; "hunch"; "back"; "roll"; "small"];
numberofactions=length(actionsperformed);

% the actions and conditions you want to plot together
actionstoplot=[2 4];
conditionstoplot=[1 2 3];


%% Extract probabilities and number of larvae for all conditions
% ! avoid spaces !
% ! care with the organization of data ! see top explanations

%get all folders contained in the main folder in the directory; each folder=one condition
dossierppal=dir(adresse);
%get all the folders identities (conditions)
dirparcondition=find(vertcat(dossierppal.isdir));
dossiersparconditions=dossierppal(dirparcondition);
nombredeconditions=length(dirparcondition)-2;
titres=[];
probafinal=struct;
for condition=1:nombredeconditions
    titres=[titres; string(dossiersparconditions(condition+2).name)];
    [probafinal.(titres(condition)), t, actionsperformed]=combinepipeline([dossiersparconditions(condition+2).folder '\' dossiersparconditions(condition+2).name '\'],titres(condition));
end
xcat=categorical(titres);
%% Replot data together
% The probabilities of performing a given action over time for each
% condition are plot together on a graph which is saved; moreover, the
% graph of the number of larvae followed over time in each condition is
% also saved.

nombredactions=length(actionsperformed);
for action=1:nombredactions
    figure
    hold on
    actionname=actionsperformed(action);
    for condition=1:nombredeconditions
        couleur=couleurs(condition,:);
        conditionname=titres(condition);
        plot(t, probafinal.(conditionname).(actionname).data, 'color', couleur)
    end
    if action==4 % hunch
        xlim([58 64]);
    end
    title(actionname);
    legend(regexprep(titres,'_',''));
    xlabel('Time (s)');
    ylabel('Probability of action');
    set(gca,'box','off')
    filename=[adresse char(actionname) 'all'];
    saveas(gcf,[filename '.fig']);
    saveas(gcf,[filename '.png']);
end

figure
hold on
for condition=1:nombredeconditions
    couleur=couleurs(condition,:);
    conditionname=titres(condition);
    plot(t, probafinal.(conditionname).(actionname).numberoflarvae, 'color', couleur)
end
title('Number of larvae');
legend(regexprep(titres,'_',''));
xlabel('Time (s)');
ylabel('Number of larvae tracked');
set(gca,'box','off')
filename=[adresse 'numberoflarvae'];
saveas(gcf,[filename '.fig']);
saveas(gcf,[filename '.png']);

%% Calculate and plot corrected data
% the same data is corrected by substracting the mean probability of performing
% the action during the baseline

t1=timewindows(1,1); % time when baseline begins
t2=timewindows(1,2); % time when baseline ends
x1=find(t==t1); % index when baseline begins in the time and action arrays
x2=find(t==t2); % index when baseline ends in the time and action arrays
probacorrected=struct; % will store the corrected probabilities
for action=1:nombredactions
    actionname=actionsperformed(action);
    figure
    hold on
    
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        moyenne=mean(probafinal.(conditionname).(actionname).data(x1:x2));
        probacorrected.(conditionname).(actionname).data=probafinal.(conditionname).(actionname).data-moyenne;
        couleur=couleurs(condition,:);
        plot(t, probacorrected.(conditionname).(actionname).data, 'color', couleur)
    end
    if action==4 % hunch
        xlim([58 64]);
    end
    title(actionname);
    legend(regexprep(titres,'_',''));
    xlabel('Time (s)');
    ylabel('Probability of action');
    set(gca,'box','off')
    filename=[adresse char(actionname) 'all_corrected'];
    saveas(gcf,[filename '.fig']);
    saveas(gcf,[filename '.png']);
end

%% Integrate data over time windows of interest for not corrected data

integration=struct;
for timewindow=1:numberofwindows
    windowname=['window' num2str(floor(timewindows(timewindow,1))) 's_' num2str(floor(timewindows(timewindow,2))) 's'];
    t1=timewindows(timewindow,1);
    t2=timewindows(timewindow,2);
    x1=find(t==t1);
    x2=find(t==t2)-1;
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        for action=1:nombredactions
            actionname=actionsperformed(action);
            integration.(actionname).(conditionname).(windowname).data=wmean(probafinal.(conditionname).(actionname).data(x1:x2),probafinal.(conditionname).(actionname).numberoflarvae(x1:x2));
            integration.(actionname).(conditionname).(windowname).larvesapprox=mean(probafinal.(conditionname).(actionname).numberoflarvae(x1:x2));
        end
    end
end
save([adresse 'integration'], 'integration');

%% Plot data for windows of interest (except for Roll and Small actions)

xcat2=categorical({'Crawl','Bend','Stop','Hunch','Backup'});
for windowtoplot=2:numberofwindows
    windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
    datatoplot=NaN(length(xcat2),nombredeconditions);
    for action=1:nombredactions-2
        actionname=actionsperformed(action);
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            datatoplot(action,condition)=integration.(actionname).(conditionname).(windowname).data;
        end
    end
    figure
    hold on
    A=bar(xcat2,datatoplot);
    A(1).FaceColor = couleurs(1,:);
    A(2).FaceColor = couleurs(2,:);
    legend(regexprep(titres,'_',''))
    ylabel('Probability (%)');
    set(gca,'fontsize',24) ;
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    title(regexprep(windowname,'_',''));
    filename=[adresse windowname '_barplot'];
    saveas(gcf,[filename '.fig']);
    saveas(gcf,[filename '.png']);
end

%% Integrate corrected data over time windows of interest

integration_corrected=struct;
for timewindow=1:numberofwindows
    windowname=['window' num2str(floor(timewindows(timewindow,1))) 's_' num2str(floor(timewindows(timewindow,2))) 's'];
    t1=timewindows(timewindow,1);
    t2=timewindows(timewindow,2);
    x1=find(t==t1);
    x2=find(t==t2)-1;
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        for action=1:nombredactions
            actionname=actionsperformed(action);
            integration_corrected.(actionname).(conditionname).(windowname).data=wmean(probacorrected.(conditionname).(actionname).data(x1:x2),probafinal.(conditionname).(actionname).numberoflarvae(x1:x2));
            integration_corrected.(actionname).(conditionname).(windowname).larvesapprox=mean(probafinal.(conditionname).(actionname).numberoflarvae(x1:x2));
        end
    end
end
save([adresse 'integration_corrected'], 'integration_corrected');

%% Plot corrected data for windows of interest (except for Small actions and roll)

xcat2=categorical({'Crawl','Bend','Stop','Hunch','Backup'});
for windowtoplot=2:numberofwindows
    windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
    actionstoplot=[1 2 3 4 5];
    datatoplot=NaN(length(xcat2),length(conditionstoplot));
    decompteaction=1;
    for action=actionstoplot
        actionname=actionsperformed(action);
        decomptecondition=1;
        for condition=conditionstoplot
            conditionname=titres(condition);
            datatoplot(decompteaction,decomptecondition)=integration_corrected.(actionname).(conditionname).(windowname).data;
            decomptecondition=decomptecondition+1;
        end
        decompteaction=decompteaction+1;
    end
    figure
    hold on
    A=bar(xcat2,datatoplot);
    A(1).FaceColor = couleurs(1,:);
    A(2).FaceColor = couleurs(2,:);
    legend(regexprep(titres,'_',''))
    ylabel('Corrected probability from baseline (%)');
    set(gca,'fontsize',24) ;
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    title(regexprep(windowname,'_',''));
    filename=[adresse windowname '_barplot_norm'];
    saveas(gcf,[filename '.fig']);
    saveas(gcf,[filename '.png']);
end

%% Plot the probabilities of actions in two categories : startle or escape responses
% startle : hunch, stop
% escape : crawl, backup, bend

xcat3=categorical({'Escape','Startle'});
for windowtoplot=2:numberofwindows
    windowname=['window' num2str(floor(timewindows(windowtoplot,1))) 's_' num2str(floor(timewindows(windowtoplot,2))) 's'];
    datatoplot=NaN(length(xcat3),nombredeconditions);
    for action=1:2
        actionname=char(xcat3(action));
        for condition=1:nombredeconditions
            conditionname=titres(condition);
            if action==1
                datatoplot(action,condition)=integration.cast.(conditionname).(windowname).data+integration.run.(conditionname).(windowname).data+integration.back.(conditionname).(windowname).data;
            else
                datatoplot(action,condition)=integration.hunch.(conditionname).(windowname).data+integration.stop.(conditionname).(windowname).data;
            end
        end
    end
    figure
    hold on
    A=bar(xcat3,datatoplot);
    A(1).FaceColor = couleurs(1,:);
    A(2).FaceColor = couleurs(2,:);
    legend(regexprep(titres,'_',''))
    ylabel('Probability (%)');
    set(gca,'fontsize',24) ;
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    title(regexprep(windowname,'_',''));
    filename=[adresse windowname '_escapeorstartle_barplot'];
    saveas(gcf,[filename '.fig']);
    saveas(gcf,[filename '.png']);
end

%% Plot only windows and actions of interest

% for timewindow=1:numberofwindows
%     windowname=['window' num2str(floor(timewindows(timewindow,1))) 's_' num2str(floor(timewindows(timewindow,2))) 's'];
%
%     actionaploter=1;
%     datatoplot=[];
%     for action=actionstoplot
%         actionname=actionsperformed(action);
%         figure
%         hold on
%         conditionaploter=1;
%         for condition=conditionstoplot
%             conditionname=titres(condition);
%             datatoplot(actionaploter,conditionaploter)=integration.(actionname).(conditionname).(windowname).data*100;
%             A=bar(xcat(conditionaploter),datatoplot(actionaploter,conditionaploter));
%             A.FaceColor=couleurs(condition,:);
%             conditionaploter=conditionaploter+1;
%         end
%
%         ylabel('Probability (%)');
%         set(gca,'fontsize',24) ;
%         yl=ylim;
%         yl(2)=yl(2)+5;
%         ylim(yl);
%         title(actionname);
%         title(regexprep([actionname '--' windowname],'_',''));
%         filename=[adresse windowname '  ' char(actionname) '_' 'all' char(conditionname)];
%         saveas(gcf,[filename '.fig']);
%         saveas(gcf,[filename '.png']);
%
%         actionaploter=actionaploter+1;
%     end
%
% end

%% Plot the ratio of hunch over bend, calculated from corrected data

for window=3
    windowname=['window' num2str(floor(timewindows(window,1))) 's_' num2str(floor(timewindows(window,2))) 's'];
    datatoplot=[];
    figure
    hold on
    for condition=1:nombredeconditions
        conditionname=titres(condition);
        datatoplot(condition)=integration_corrected.hunch.(conditionname).(windowname).data/integration_corrected.cast.(conditionname).(windowname).data;
        A=bar(xcat(condition),datatoplot(condition));
        A.FaceColor = couleurs(condition,:);
    end
    legend(regexprep(titres,'_',''))
    ylabel('Hunch over bend ratio');
    title(regexprep(windowname,'_',''));
    plot([xcat(1), xcat(end)],[1 1],'-k');
    filename=[adresse windowname '_hunchoverbend'];
    saveas(gcf,[filename '.fig']);
    saveas(gcf,[filename '.png']);
end