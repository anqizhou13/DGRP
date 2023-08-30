function [transition_globale, transition_globale_norm]=transitionFromTrx(trx, times)

t_init=times(1,1);
t_end=times(1,2);
states=["run";"cast";"stop";"hunch";"back";"roll";"small_actions";"backup_sequence";"bend_static"];

n_trx=length(trx);
n_behaviour=length(states);
transition_globale=zeros(n_behaviour,n_behaviour);
dt_theo=t_end-t_init; % -dt?? % time duration of the window of interest

nb_active=0; % we will increment this number with the active larvae
nb_transition=zeros(n_behaviour,1);
for larva=1:n_trx % scan all larvae in trx file
    t_loc=trx(larva).t;
    
    % scan if tracked
    timestracked=find((t_loc>=t_init)&(t_loc<=t_end)); % take all times during which the larva is tracked in the time window
    timestracked_loc=t_loc(timestracked);
    states_loc=trx(larva).global_state_large_state(timestracked);
    if  isempty(states_loc)==0 % if this larva is behaving during the time window defined
        % find the periods of transitions between actions
        transitionstootheraction=find(diff(states_loc)~=0);
        if isempty(transitionstootheraction)==0
            transition_globale_loc=zeros(n_behaviour,n_behaviour);
            for j=1:length(transitionstootheraction)
                action_start=states_loc(transitionstootheraction(j));
                action_end=states_loc(transitionstootheraction(j)+1);
                nb_transition(action_start)=nb_transition(action_start)+1; % increment number of transitions from that action
                transition_globale_loc(action_start,action_end) = transition_globale_loc(action_start, action_end)+1;
            end
            if (sum(transition_globale_loc(:))>0)
                nb_active=nb_active+1;
            end
            transition_globale=transition_globale+transition_globale_loc;
        end
        clear global_state II JJ wi k_start k_end transition_globale_loc;
    end
end
transition_globale_norm=transition_globale./nb_transition;

end