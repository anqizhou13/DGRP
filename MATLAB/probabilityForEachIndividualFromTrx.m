function [individual_probabilities, timestracked] = probabilityForEachIndividualFromTrx(trx, action, times)
% probabilityOfActionFromTrx calculates the probability of actions from the
% trx file, including if they exist the probability of backup sequence
%%
t_min=times(1,1); %s
t_max=times(1,2); %s
n_trx=length(trx); % determines the number of larva tracked

timestracked=NaN(1,n_trx);
individual_probabilities=NaN(1,n_trx);
% Begin the loop for scanning larvae
for larva=1:n_trx
    t_loc=trx(larva).t;
    interestingtimes=(t_loc>t_min)&(t_loc<=t_max); % take all times during which the larva is tracked DURING ONE TIME STEP
    timestracked(1,larva)=max(interestingtimes)-min(interestingtimes);
    states_loc= trx(larva).(action)(interestingtimes); % take the states during this time period
    if isempty(states_loc)
    else % if indeed there are defined states during this time window
        individual_probabilities(1,larva)=mean(states_loc); % probability for the larva of performing the action during the time step ! does not take into account the fact that all larvae are not tracked during the same time !
    end
end