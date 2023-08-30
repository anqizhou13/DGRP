function [probainterest, numberoflarvaeinterest]=cumulativeAfterStimNotContinuing(trx,action,tfin)

t1=60;
t2=tfin;
tm1=59;
tm2=59.5;
numberoflarvae=length(trx);

%% Check if larvae perform the action before the stimulus
actionornoaction=NaN(numberoflarvae,1);
for larva=1:numberoflarvae
    t_loc=trx(larva).t;
    larva_action=NaN(length(t_loc),1);
    % scan if tracked
    II=(t_loc>=tm1)&(t_loc<=tm2); % take all times during which the larva is tracked in the time window
    states_loc=trx(larva).global_state_large_state(II); % take the states during this time period
    if isempty(states_loc)
    else % if indeed there are defined states during this time window
        if isempty(find(states_loc==action))
            larva_action(states_loc==action)=0;
        else % if the larva scanned has performed the action during the time window
            larva_action(states_loc==action)=1;
        end
    end
    actionornoaction(larva,1)=nanmean(larva_action);
end


%% Check if larvae perform the action after the stimulus

activelarva=NaN(numberoflarvae,1);
actionlarva=NaN(numberoflarvae,1);

for larva=1:numberoflarvae
    t_loc=trx(larva).t;
    % scan if tracked
    II=(t_loc>=t1)&(t_loc<=t2); % take all times during which the larva is tracked in the time window
    states_loc=trx(larva).global_state_large_state(II); % take the states during this time period
    if isempty(states_loc)
    else % if indeed there are defined states during this time window
        if isempty(find(states_loc==action))
        else % if the larva scanned has performed the action during the time window
            if actionornoaction(larva,1)<0.8 || isnan(actionornoaction(larva,1))==1 % if the larva was not doing the action right before the stimulus
                actionlarva(larva,1)=1;
            else
                actionlarva(larva,1)=0;
            end
        end
        activelarva(larva,1)=1; % the number of active larvae during this time window is incremented
    end
end
numberoflarvaeinterest=nansum(activelarva);
probainterest=nansum(actionlarva)/numberoflarvaeinterest;

end