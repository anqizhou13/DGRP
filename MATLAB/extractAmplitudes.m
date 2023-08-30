function dataout=extractAmplitudes(adresse, timewindows)
% extractAmplitude extracts amplitude data from trx.mat files, in a
% structure that contains the amplitudes for the different actions, along
% with the time spent doing the different actions, for given time windows

%% Initialize by extracting trx.mat file and .puff file

dirtrx=[adresse '\trx*.mat'];
load('-mat', dirtrx);

% Use when possible to correlate position with air puff intensity
% dirpuffextract=dir([adresse '\*.puff']);
% dirpuff=[adresse '\' dirpuffextract.name];
% puff=importdata(dirpuff);

%% Set the objects that will contain the actions and simple parameters of larvae during the different time windows
numberoflarvae=length(trx);
actionLarva=struct; % to store the action of the larva over time
XY=struct; % to store the position of the larvae at the begining of the stimulus

% for runs
speedrun=struct; % to store speed during runs
pathlength=struct; % to store initial and final coordinates to calculate speed during runs
timerun=struct;

% for bend
bend=struct; % to calculate amplitude of bend (with S) only during bend
timebend=struct;

% for hunch
length0Larva=NaN(numberoflarvae,1); % to store mean initial length of the larva
lengthLarva=struct; % to store mean length of the larva during the hunch relative to its baseline length
hunchAmplitude=struct;
timehunch=struct;

% for backups
speedback=struct;
pathlengthback=struct;
timeback=struct;

numberoflarvae=length(trx); % to create the loop to analyze all larvae, larva by larva

%% Loop with the different time windows

for timewindow=1:length(timewindows)
    windowname=['window' num2str(timewindow)];
    
    % Calculate initial length of larvae
    if timewindow==1
        for numberlarva=1:numberoflarvae
            transit=find(trx(numberlarva).t>=timewindows(timewindow,1)&trx(numberlarva).t<=timewindows(timewindow,2));
            if isempty(transit)==0
                indexofinterest=[min(transit) max(transit)];
                length0Larva(numberlarva,1)=wmean(trx(numberlarva).larva_length_smooth_5(indexofinterest(1):indexofinterest(2)),trx(numberlarva).t(indexofinterest(1):indexofinterest(2)));
            end
        end
    end
    
    % Create a substructure containing each time window of interest for each parameter
    % for all
    actionLarva.(windowname)=struct;
    XY.(windowname)=struct;
    % for runs
    speedrun.(windowname)=struct;
    pathlength.(windowname)=struct;
    timerun.(windowname)=struct;
    % bend
    bend.(windowname)=struct;
    dbend.(windowname)=struct; %% SEE WHEN TO DECIPHER DYNAMIC/STATIC
    timebend.(windowname)=struct;
    % stop
    % hunch
    lengthLarva.(windowname)=struct;
    hunchAmplitude.(windowname)=struct;
    timehunch.(windowname)=struct;
    % for backups
    speedback.(windowname)=struct;
    pathlengthback.(windowname)=struct;
    timeback.(windowname)=struct;
    
    for numberlarva=1:numberoflarvae
        larvaname=['larva' num2str(numberlarva)];
        
        % all
        XY.(windowname).(larvaname)=[];
        
        % run
        timerun.(windowname).(larvaname)=struct;
        timerun.(windowname).(larvaname).actions=[];
        timerun.(windowname).(larvaname).total=[];
        speedrun.(windowname).(larvaname)=struct;
        speedrun.(windowname).(larvaname).actions=[];
        speedrun.(windowname).(larvaname).total=[];
        pathlength.(windowname).(larvaname)=struct;
        pathlength.(windowname).(larvaname).actions=[];
        pathlength.(windowname).(larvaname).mean=[];
        
        % bend
        bend.(windowname).(larvaname)=struct;
        bend.(windowname).(larvaname).actions=[];
        bend.(windowname).(larvaname).mean=[];
        timebend.(windowname).(larvaname).actions=[];
        timebend.(windowname).(larvaname).total=[];
        
        % hunch
        lengthLarva.(windowname).(larvaname)=struct;
        lengthLarva.(windowname).(larvaname).actions=[];
        lengthLarva.(windowname).(larvaname).mean=[];
        timehunch.(windowname).(larvaname)=struct;
        timehunch.(windowname).(larvaname).actions=[];
        timehunch.(windowname).(larvaname).total=[];
        hunchAmplitude.(windowname).(larvaname)=struct;
        hunchAmplitude.(windowname).(larvaname).actions=[];
        hunchAmplitude.(windowname).(larvaname).mean=[];
        
        % for backups
        timeback.(windowname).(larvaname)=struct;
        timeback.(windowname).(larvaname).actions=[];
        timeback.(windowname).(larvaname).total=[];
        speedback.(windowname).(larvaname)=struct;
        speedback.(windowname).(larvaname).actions=[];
        speedback.(windowname).(larvaname).total=[];
        pathlengthback.(windowname).(larvaname)=struct;
        pathlengthback.(windowname).(larvaname).actions=[];
        pathlengthback.(windowname).(larvaname).mean=[];
        
        transit=find(trx(numberlarva).t>=timewindows(timewindow,1)&trx(numberlarva).t<=timewindows(timewindow,2));
        
        if isempty(transit)==0
            indexofinterest=[min(transit) max(transit)];
            times=trx(numberlarva).t(indexofinterest(1):indexofinterest(2));
            %             timewininterest=[times(1) times(end)];
            actionLarva.(windowname).(larvaname)=trx(numberlarva).global_state_large_state(indexofinterest(1):indexofinterest(2));
            XY.(windowname).(larvaname)(1,1)= trx(numberlarva).x_center(indexofinterest(1,1)); % X coordinates of center of mass
            XY.(windowname).(larvaname)(1,2)= trx(numberlarva).x_center(indexofinterest(1,2)); % X coordinates of center of mass
            XY.(windowname).(larvaname)(2,1)= trx(numberlarva).y_center(indexofinterest(1,1)); % Y coordinates of center of mass
            XY.(windowname).(larvaname)(2,2)= trx(numberlarva).y_center(indexofinterest(1,2)); % Y coordinates of center of mass
            
            % Measure parameters for all actions
            for actiontolook=1:7
                timesforaction=find(actionLarva.(windowname).(larvaname)==actiontolook);
                if isempty(timesforaction)==0 % if indeed the larva peformed the action during that time window
                    if successiveNumbers(timesforaction)==0 % if several periods of runs
                        beginend = findSuccessiveNumbers(timesforaction); % table that contains one line for begining the time sequence of this action, and one line for the end
                    else % if only one period of run
                        beginend=[timesforaction(1) timesforaction(end)];
                    end
                    repetitionofaction=size(beginend,1);
                    
                    if actiontolook==1 % crawl/run
                        for actioncount=1:repetitionofaction
                            
                            % calculate time of run
                            timerun.(windowname).(larvaname).actions(actioncount,1)=times(beginend(actioncount,2))-times(beginend(actioncount,1));
                            
                            % calculate total pathlength over the session of run
                            dist=0;
                            if beginend(actioncount,2)-beginend(actioncount,1)>=2
                                for dt = beginend(actioncount,1)+1:beginend(actioncount,2)
                                    dist=dist+sqrt((trx(numberlarva).x_center(dt)-(trx(numberlarva).x_center(dt-1)))^2+(trx(numberlarva).y_center(dt)-(trx(numberlarva).y_center(dt-1)))^2);
                                end
                                pathlength.(windowname).(larvaname).actions(actioncount)=dist;
                            else
                                pathlength.(windowname).(larvaname).actions(actioncount)=NaN;
                            end
                            speedrun.(windowname).(larvaname).actions(actioncount)=pathlength.(windowname).(larvaname).actions(actioncount)/timerun.(windowname).(larvaname).actions(actioncount);
                        end
                        if nansum(timerun.(windowname).(larvaname).actions)~= 0
                            timerun.(windowname).(larvaname).total=nansum(timerun.(windowname).(larvaname).actions(:)); % calculate total time of runs
                            pathlength.(windowname).(larvaname).total=nansum(pathlength.(windowname).(larvaname).actions);
                            % calculate run speed
                            speedrun.(windowname).(larvaname).total=pathlength.(windowname).(larvaname).total/timerun.(windowname).(larvaname).total;
                        end
                        
                    elseif actiontolook==2 % bend
                        for actioncount=1:repetitionofaction
                            bend.(windowname).(larvaname).actions(actioncount,1)=wmean(trx(numberlarva).S(beginend(actioncount,1):beginend(actioncount,2)),trx(numberlarva).t(beginend(actioncount,1):beginend(actioncount,2)));
                            timebend.(windowname).(larvaname).actions(actioncount,1)=times(beginend(actioncount,2))-times(beginend(actioncount,1));
                        end
                        if isempty(find(timebend.(windowname).(larvaname).actions~= 0))==1 % if there is only one image during which the action in accomplished
                            
                            actionsNOcount = find(timebend.(windowname).(larvaname).actions == 0);
                            bendephemere=bend.(windowname).(larvaname).actions(setdiff(1:repetitionofaction, actionsNOcount));
                            if isempty(bendephemere)==0
                                bend.(windowname).(larvaname).mean=wmean(bendephemere,timebend.(windowname).(larvaname).actions(setdiff(1:repetitionofaction, actionsNOcount))); % weighted mean depending on the time spent bending
                            else
                                bend.(windowname).(larvaname).mean=mean(bend.(windowname).(larvaname).actions);
                            end
                        else
                            bend.(windowname).(larvaname).mean=wmean(bend.(windowname).(larvaname).actions,timebend.(windowname).(larvaname).actions); % weighted mean depending on the time spent bending
                        end
                        timebend.(windowname).(larvaname).total=sum(timebend.(windowname).(larvaname).actions);
                        
                    elseif actiontolook==4 % hunch
                        for actioncount=1:repetitionofaction
                            lengthLarva.(windowname).(larvaname).actions(actioncount,1)=wmean(trx(numberlarva).larva_length_smooth_5(beginend(actioncount,1):beginend(actioncount,2)),trx(numberlarva).t(beginend(actioncount,1):beginend(actioncount,2)));
                            timehunch.(windowname).(larvaname).actions(actioncount,1)=trx(numberlarva).t(beginend(actioncount,2))-trx(numberlarva).t(beginend(actioncount,1));
                        end
                        
                        if isempty(find(timehunch.(windowname).(larvaname).actions~= 0))==1
                            actionsNOcount = find(timehunch.(windowname).(larvaname).actions == 0);
                            hunchephemere=lengthLarva.(windowname).(larvaname).actions(setdiff(1:repetitionofaction, actionsNOcount));
                            if isempty(hunchephemere)==0
                                lengthLarva.(windowname).(larvaname).mean=wmean(hunchephemere,timebend.(windowname).(larvaname).actions(setdiff(1:repetitionofaction, actionsNOcount))); % weighted mean depending on the time spent bending
                            else
                                lengthLarva.(windowname).(larvaname).mean=mean(lengthLarva.(windowname).(larvaname).actions);
                            end
                        else
                            lengthLarva.(windowname).(larvaname).mean=wmean(lengthLarva.(windowname).(larvaname).actions,timehunch.(windowname).(larvaname).actions);
                        end
                        timehunch.(windowname).(larvaname).total=sum(timehunch.(windowname).(larvaname).actions);
                        
                        if isnan(length0Larva(numberlarva,1))==0
                            hunchAmplitude.(windowname).(larvaname).actions=lengthLarva.(windowname).(larvaname).actions/length0Larva(numberlarva,1);
                            hunchAmplitude.(windowname).(larvaname).mean=lengthLarva.(windowname).(larvaname).mean/length0Larva(numberlarva,1);
                        else
                            hunchAmplitude.(windowname).(larvaname).actions=NaN;
                            hunchAmplitude.(windowname).(larvaname).mean=NaN;
                        end
                        
                    elseif actiontolook==5 % backup
                        for actioncount=1:repetitionofaction
                            
                            % calculate time of run
                            timeback.(windowname).(larvaname).actions(actioncount,1)=times(beginend(actioncount,2))-times(beginend(actioncount,1));
                            
                            % calculate total pathlength over the session of run
                            dist=0;
                            if beginend(actioncount,2)-beginend(actioncount,1)>=2
                                for dt = beginend(actioncount,1)+1:beginend(actioncount,2)
                                    dist=dist+sqrt((trx(numberlarva).x_center(dt)-(trx(numberlarva).x_center(dt-1)))^2+(trx(numberlarva).y_center(dt)-(trx(numberlarva).y_center(dt-1)))^2);
                                end
                                pathlengthback.(windowname).(larvaname).actions(actioncount)=dist;
                            else
                                pathlengthback.(windowname).(larvaname).actions(actioncount)=NaN;
                            end
                            speedback.(windowname).(larvaname).actions(actioncount)=pathlengthback.(windowname).(larvaname).actions(actioncount)/timeback.(windowname).(larvaname).actions(actioncount);
                        end
                        if nansum(timeback.(windowname).(larvaname).actions)~= 0
                            timeback.(windowname).(larvaname).total=nansum(timeback.(windowname).(larvaname).actions(:)); % calculate total time of runs
                            pathlengthback.(windowname).(larvaname).total=nansum(pathlengthback.(windowname).(larvaname).actions);
                            % calculate run speed
                            speedback.(windowname).(larvaname).total=pathlengthback.(windowname).(larvaname).total/timeback.(windowname).(larvaname).total;
                        end
                    end
                end
            end
        end
    end
end

dataout.XY=XY;
dataout.crawl.speed=speedrun; % speed is run amplitude
dataout.crawl.time=timerun;
dataout.bend.amplitude=bend;
dataout.bend.time=timebend;
dataout.hunch.amplitude=hunchAmplitude;
dataout.hunch.time=timehunch;
dataout.back.speed=speedback; % speed is backup amplitude
dataout.back.time=timeback;
end