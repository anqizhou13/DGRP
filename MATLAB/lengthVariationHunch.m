function [relative_variation_l ,ratio_l, nb_active_larva] = average_length_variation_hunch(trx);

t_start=60;
dt=10;
dt_short=2;
state='hunch';
n_trx=length(trx);

t_before=t_start-dt;
t_after=t_start+ dt_short;

loc_variation = [];
loc_ratio = [];
nb_active = 0;    
nb_active_larva = nan;

for i = 1 : n_trx
    l     = trx(i).larva_length_smooth_5;
    t     = trx(i).t;
    state_loc = trx(i).(state);
    II    = (t>=t_before)&(t<=t_start); % time before stim
    JJ    = (t>=t_start)&(t<=t_after); % time after stim
    KK    = state_loc ==1 ;
    LL    = KK & JJ ; % we keep the times contained in the time window after stim when larvae crawl
    l_max = max(l(II)); % we get max length during the time window before start of stim
    l_min = min(l(LL)); % we get min length during the time window after start, when larva was hunching
    variation = (l_min - l_max)./l_max;
    ratio     = l_min /l_max;
    
    if (  isempty(l_max) || isempty(l_min) )
    else
        loc_variation = [loc_variation; variation];
        loc_ratio     = [loc_ratio; ratio];
        nb_active     = nb_active + 1; 
    end
    clear II JJ KK LL l_min l_max state_loc;
end

if  isempty(loc_variation) || isempty(loc_ratio)
    relative_variation_l = nan;
    ratio_l              = nan;
else
    relative_variation_l = sum(loc_variation)./nb_active;
    ratio_l              = sum(loc_ratio)./nb_active;
    nb_active_larva      = nb_active;
end
end
    