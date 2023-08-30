function [probainterest, probacontrol, numberoflarvaeinterest, numberoflarvaecontrol]=cumulativeFromTrx(trx, timewindows, action)

% define time window that we analyze
numberoflarvae=length(trx);
t1=timewindows(1,1);
t2=timewindows(1,2);
ttot=t2-t1; % total length of the window

% define control time window, of the same length as the window of interest
t2control=59;
t1control=59-ttot;

nb_larva_action=0;
nb_active_larva=0;

for larva=1:numberoflarvae
    t_loc=trx(larva).t;
    % scan if tracked
    II=(t_loc>=t1)&(t_loc<=t2); % take all times during which the larva is tracked in the time window
    states_loc=trx(larva).global_state_large_state(II); % take the states during this time period
    if isempty(states_loc)
    else % if indeed there are defined states during this time window
        if isempty(find(states_loc==action))
        else % if the larva scanned has performed the action during the time window
            nb_larva_action=nb_larva_action+1;
        end
        nb_active_larva=nb_active_larva+1; % the number of active larvae during this time window is incremented
    end
end
probainterest=nb_larva_action/nb_active_larva;
numberoflarvaeinterest=nb_active_larva;


nb_larva_action=0;
nb_active_larva=0;
for larva=1:numberoflarvae
    t_loc=trx(larva).t;
    % scan if tracked
    II=(t_loc>=t1control)&(t_loc<=t2control); % take all times during which the larva is tracked in the time window
    states_loc=trx(larva).global_state_large_state(II); % take the states during this time period
    if isempty(states_loc)
    else % if indeed there are defined states during this time window
        if isempty(find(states_loc==action))
        else % if the larva scanned has performed the action during the time window
            nb_larva_action=nb_larva_action+1;
        end
        nb_active_larva=nb_active_larva+1; % the number of active larvae during this time window is incremented
    end
end
probacontrol=nb_larva_action/nb_active_larva;
numberoflarvaecontrol=nb_active_larva;
end