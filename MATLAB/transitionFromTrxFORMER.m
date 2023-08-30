trx=TRX.AttP240;
t_init=60;
t_end=62;
states=["run";"cast";"stop";"hunch";"back";"roll";"small_actions";"backup_sequence";"bend_static"];
factor=0.05; % not really understood, used to have integers after in probabilities of transitions
% dt=1; %????

n_trx=length(trx);
n_behaviour=length(states);
transition_globale=zeros(n_behaviour,n_behaviour);
dt_theo=t_end-t_init; % -dt?? % time duration of the window of interest

nb_active=0; % we will increment this number with the active larvae
nb_transition=0;
for larva=1:n_trx % scan all larvae in trx file
    t_loc=trx(larva).t;
    
    % scan if tracked
    timestracked=find((t_loc>=t_init)&(t_loc<=t_end)); % take all times during which the larva is tracked in the time window
    timestracked_loc=t_loc(timestracked);
    states_loc=trx(larva).global_state_large_state(timestracked);
    if  isempty(states_loc)==0 % if this larva is behaving during the time window defined
        dt_window=max(timestracked_loc)-min(timestracked_loc); % period of time during which it is tracked
        wi=min(dt_window./dt_theo, 1); % relative window of interest, minimum between the maximum theoretical time window and the window when the larva is tracked
        
        % find the periods of transitions between actions
        transitionstootheraction=find(diff(states_loc)~=0);
        if isempty(transitionstootheraction)==0
            nb_transition=nb_transition+length(transitionstootheraction);
            transition_globale_loc=zeros(n_behaviour,n_behaviour);
            for j=1:length(transitionstootheraction)
                action_start=states_loc(transitionstootheraction(j));
                action_end=states_loc(transitionstootheraction(j)+1);
                transition_globale_loc(action_start,action_end) = transition_globale_loc(action_start, action_end)+wi; %
            end
%             transition_globale_loc = round(tanh(transition_globale_loc./factor ));
            if (sum(transition_globale_loc(:))>0)
                nb_active=nb_active+1;
            end
            transition_globale=transition_globale+transition_globale_loc;
        end
        clear global_state II JJ wi k_start k_end transition_globale_loc;
    end
end
transition_globale=transition_globale/nb_transition