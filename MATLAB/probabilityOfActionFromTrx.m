function proba = probabilityOfActionFromTrx(trx, action, times)
% probabilityOfActionFromTrx calculates the probability of actions from the
% trx file, including if they exist the probability of backup sequence
%%
t_min=times(1,1); %s
t_max=times(1,2); %s
dt      = 0.1; % define time step in s
t_debut = t_min-2*dt; % define time when classification begin : after 1s
t_fin   = t_max+2*dt; % define time when it ends : at 149s
t       = [t_debut:dt:t_fin]; % define all time steps in vector t
n_trx   = length(trx); % detemines the number of larva tracked

% Begin the loop for scanning actions performed by larvae
nb_active_larva = NaN(1,length(t));
values_mean=NaN(1,length(t));
values_error=NaN(1,length(t));

for i  = 1 : length(t) % define all time steps in order to write the probabilities
    loc = [];
    nb_active = 0;
    for j = 1 : n_trx % scan all larvae
        t_loc      = trx(j).t; % times during which the larva is tracked
        
        % CHANGE from Masson: dt=100ms
        %%% II         = (t_loc>t(i)-dt)&(t_loc<t(i)+dt); % take all times during which the larva is tracked between two time steps being written
        II         = (t_loc>t(i)-dt)&(t_loc<=t(i)+dt); % take all times during which the larva is tracked DURING ONE TIME STEP
        states_loc     = trx(j).(action)(II); % take the states during this time period
        if isempty(states_loc)
        else % if indeed there are defined states during this time window
            
            % CHANGE from Masso: no need to switch numbers that are already
            % zeros
            %%% KK         = states_loc < 1;
            %%% states_loc(KK) = 0; % convert -1 to 0 in all states
            loc        = [loc; mean(states_loc)]; % probability for the larva of performing the action during the time step ! does not take into account the fact that all images are not taken with the same time !
            nb_active  = nb_active + 1; % the number of active larvae during this time window is incremented
        end
    end
    if  isempty(loc) % if during this period of time, no larvae were tracked
        values_mean(1,i) = nan;
        value_error(1,i) = nan;
    else % if indeed larvae were tracked
        values_mean(1,i)     = sum(loc)./nb_active; % calculate the mean probability of performing the action
        value_error(1,i)     = sum((values_mean(i)-loc).^2 )./nb_active; % !! should be nb_active-1 to calculate properly
        value_error(1,i)     = sqrt(value_error(i))./sqrt(nb_active); % sem
        nb_active_larva(1,i) = nb_active;
    end
end

proba=[t; values_mean; nb_active_larva];
proba=proba.'; % 1st column: time, 2nd: mean probability; 3rd: number of larvae tracked during the time step

