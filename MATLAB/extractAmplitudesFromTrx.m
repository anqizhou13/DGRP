function dataout=extractAmplitudesFromTrx(trx, timewindows)
% extractAmplitude extracts amplitude data from a trx.mat file, in a
% structure that contains the amplitudes for the different actions, along
% with the time spent doing the different actions, for given time windows

%% Set the objects that will contain the actions and simple parameters of larvae during the different time windows
numberoflarvae=length(trx);
length0Larva=NaN(numberoflarvae,1); % to store mean initial length of the larva

%% Loop with the different time windows

for timewindow=1:length(timewindows)
    windowname=['window' num2str(timewindow)];
    
    % Calculate initial length of larvae
    if timewindow==1
        for numberlarva=1:numberoflarvae
            transit=find(trx(numberlarva).t>=timewindows(timewindow,1)&trx(numberlarva).t<=timewindows(timewindow,2));
            if isempty(transit)==0
                indexofinterest=[min(transit) max(transit)];
                length0Larva(numberlarva,1)=max(trx(numberlarva).larva_length_smooth_5(indexofinterest(1):indexofinterest(2)));
            end
        end
    end
    
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
        
        % cast
        cast.(windowname).(larvaname)=struct;
        cast.(windowname).(larvaname).actions=[];
        cast.(windowname).(larvaname).mean=[];
        timecast.(windowname).(larvaname).actions=[];
        timecast.(windowname).(larvaname).total=[];
        
        % stop
        stop.(windowname).(larvaname)=struct;
        stop.(windowname).(larvaname).actions=[];
        stop.(windowname).(larvaname).mean=[];
        timestop.(windowname).(larvaname).actions=[];
        timestop.(windowname).(larvaname).total=[];
        
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
            times_loc=trx(numberlarva).t(indexofinterest(1):indexofinterest(2));
            actionLarva_loc=trx(numberlarva).global_state_large_state(indexofinterest(1):indexofinterest(2));
            length_loc=trx(numberlarva).larva_length_smooth_5(indexofinterest(1):indexofinterest(2));
            deriv_length_loc=trx(numberlarva).larva_length_deriv_smooth_5(indexofinterest(1):indexofinterest(2));
            S_loc=trx(numberlarva).S_smooth_5(indexofinterest(1):indexofinterest(2));
            S_deriv_loc=trx(numberlarva).S_deriv_smooth_5(indexofinterest(1):indexofinterest(2));
            velocity_loc=trx(numberlarva).motion_velocity_norm_smooth_5(indexofinterest(1):indexofinterest(2));
            head_velocity_loc=trx(numberlarva).head_velocity_norm_smooth_5(indexofinterest(1):indexofinterest(2));
            x_center_loc=trx(numberlarva).x_center(indexofinterest(1):indexofinterest(2));
            y_center_loc=trx(numberlarva).y_center(indexofinterest(1):indexofinterest(2));
            
            XY.(windowname).(larvaname)(1,1)= trx(numberlarva).x_center(indexofinterest(1,1)); % X coordinates of center of mass
            XY.(windowname).(larvaname)(1,2)= trx(numberlarva).x_center(indexofinterest(1,2)); % X coordinates of center of mass
            XY.(windowname).(larvaname)(2,1)= trx(numberlarva).y_center(indexofinterest(1,1)); % Y coordinates of center of mass
            XY.(windowname).(larvaname)(2,2)= trx(numberlarva).y_center(indexofinterest(1,2)); % Y coordinates of center of mass
            
            % Measure parameters for all actions
            for actiontolook=1:9
                timesforaction=find(actionLarva_loc==actiontolook);
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
                            timerun.(windowname).(larvaname).actions(actioncount,1)=times_loc(beginend(actioncount,2))-times_loc(beginend(actioncount,1));
                            
                            % calculate total pathlength over the session of run
                            dist=0;
                            if beginend(actioncount,2)-beginend(actioncount,1)>=2
                                for dt = beginend(actioncount,1)+1:beginend(actioncount,2)
                                    dist=dist+sqrt((x_center_loc(dt)-x_center_loc(dt-1))^2+(y_center_loc(dt)-y_center_loc(dt-1))^2);
                                end
                                pathlength.(windowname).(larvaname).actions(actioncount,1)=dist;
                            else
                                pathlength.(windowname).(larvaname).actions(actioncount,1)=NaN;
                            end
                            speedrun.(windowname).(larvaname).actions(actioncount,1)=pathlength.(windowname).(larvaname).actions(actioncount,1)/timerun.(windowname).(larvaname).actions(actioncount,1);
                        end
                        if nansum(timerun.(windowname).(larvaname).actions)~= 0
                            timerun.(windowname).(larvaname).total=nansum(timerun.(windowname).(larvaname).actions(:)); % calculate total time of runs
                            pathlength.(windowname).(larvaname).total=nansum(pathlength.(windowname).(larvaname).actions);
                            % calculate run speed
                            speedrun.(windowname).(larvaname).total=pathlength.(windowname).(larvaname).total/timerun.(windowname).(larvaname).total;
                        end
                        
                    elseif actiontolook==9 % bend
                        for actioncount=1:repetitionofaction
                            bend.(windowname).(larvaname).actions(actioncount,1)=mean(abs(head_velocity_loc(beginend(actioncount,1):beginend(actioncount,2))));
                            timebend.(windowname).(larvaname).actions(actioncount,1)=times_loc(beginend(actioncount,2))-times_loc(beginend(actioncount,1));
                        end
                        if isempty(find(timebend.(windowname).(larvaname).actions~=0))==1 % if there are no actions that last for more than an image
                        else % if some actions last more than one image
                            bend.(windowname).(larvaname).mean=wmean(bend.(windowname).(larvaname).actions,timebend.(windowname).(larvaname).actions); % weighted mean depending on the time spent bending
                        end
                        timebend.(windowname).(larvaname).total=sum(timebend.(windowname).(larvaname).actions);
                         
                    elseif actiontolook==2 % head cast
                        for actioncount=1:repetitionofaction
                            cast.(windowname).(larvaname).actions(actioncount,1)=mean(abs(head_velocity_loc(beginend(actioncount,1):beginend(actioncount,2))));
                            timecast.(windowname).(larvaname).actions(actioncount,1)=times_loc(beginend(actioncount,2))-times_loc(beginend(actioncount,1));
                        end
                        if isempty(find(timecast.(windowname).(larvaname).actions~=0))==1 % if there is only one image during which the action in accomplished
                        else
                            cast.(windowname).(larvaname).mean=wmean(cast.(windowname).(larvaname).actions,timecast.(windowname).(larvaname).actions); % weighted mean depending on the time spent casting
                        end
                        timecast.(windowname).(larvaname).total=sum(timecast.(windowname).(larvaname).actions);
                        
                    elseif actiontolook==3 % stop
                        for actioncount=1:repetitionofaction
                            timestop.(windowname).(larvaname).actions(actioncount,1)=times_loc(beginend(actioncount,2))-times_loc(beginend(actioncount,1));
                            stop.(windowname).(larvaname).actions(actioncount,1)=mean(deriv_length_loc(beginend(actioncount,1):beginend(actioncount,2)));
                        end
                        timestop.(windowname).(larvaname).total=sum(timestop.(windowname).(larvaname).actions);
                        
                    elseif actiontolook==4 % hunch
                        for actioncount=1:repetitionofaction
                            lengthLarva.(windowname).(larvaname).actions(actioncount,1)=mean(length_loc(beginend(actioncount,1):beginend(actioncount,2)));
                            timehunch.(windowname).(larvaname).actions(actioncount,1)=times_loc(beginend(actioncount,2))-times_loc(beginend(actioncount,1));
                            hunchAmplitude.(windowname).(larvaname).actions(actioncount,1)=mean(deriv_length_loc(beginend(actioncount,1):beginend(actioncount,2)));
                        end
                        
                        if isempty(find(timehunch.(windowname).(larvaname).actions~=0)) == 1 % s'il n'y a pas d'actions où le temps passé est plus que 0
                            actionsNOcount = find(timehunch.(windowname).(larvaname).actions == 0); % vérifier quelles actions ont un temps nul
                            hunchephemere=lengthLarva.(windowname).(larvaname).actions(setdiff(1:repetitionofaction, actionsNOcount)); % prélever uniquement les longueurs pour les temps non nuls
                            if isempty(hunchephemere)==0 % s'il y a des actions
                                lengthLarva.(windowname).(larvaname).mean=wmean(hunchephemere,timehunch.(windowname).(larvaname).actions(setdiff(1:repetitionofaction, actionsNOcount)));
                            else % s'il y a uniquement des actions qui ont un temps nul
                                lengthLarva.(windowname).(larvaname).mean=mean(lengthLarva.(windowname).(larvaname).actions);
                            end
                        else
                            lengthLarva.(windowname).(larvaname).mean=wmean(lengthLarva.(windowname).(larvaname).actions,timehunch.(windowname).(larvaname).actions);
                        end
                        timehunch.(windowname).(larvaname).total=sum(timehunch.(windowname).(larvaname).actions);
                        
                    elseif actiontolook==5 % backup
                        for actioncount=1:repetitionofaction
                            
                            % calculate time of run
                            timeback.(windowname).(larvaname).actions(actioncount,1)=times_loc(beginend(actioncount,2))-times_loc(beginend(actioncount,1));
                            
                            % calculate total pathlength over the session of run
                            dist=0;
                            if beginend(actioncount,2)-beginend(actioncount,1)>=2
                                for dt = beginend(actioncount,1)+1:beginend(actioncount,2)
                                    dist=dist+sqrt((x_center_loc(dt)-x_center_loc(dt-1))^2+(y_center_loc(dt)-y_center_loc(dt-1))^2);
                                end
                                pathlengthback.(windowname).(larvaname).actions(actioncount,1)=dist;
                            else
                                pathlengthback.(windowname).(larvaname).actions(actioncount,1)=NaN;
                            end
                            speedback.(windowname).(larvaname).actions(actioncount,1)=pathlengthback.(windowname).(larvaname).actions(actioncount,1)/timeback.(windowname).(larvaname).actions(actioncount,1);
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
dataout.crawl.amplitude=speedrun; % speed is run amplitude
dataout.crawl.time=timerun;
dataout.bend_static.amplitude=bend;
dataout.bend_static.time=timebend;
dataout.head_cast.amplitude=cast;
dataout.head_cast.time=timecast;
dataout.hunch.amplitude=hunchAmplitude;
dataout.hunch.time=timehunch;
dataout.backup.amplitude=speedback; % speed is backup amplitude
dataout.backup.time=timeback;
dataout.stop.amplitude=stop;
dataout.stop.time=timestop;

end