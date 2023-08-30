function actionLarva=headVSbendFromTrx(trx)

numberoflarvae=length(trx);
actionLarva=struct; % to store the action of the larva over time
% limit fixed between two backup events to consider that it is a whole backup sequence
limit_dS=0.3; % dS threshold for considering head cast VS bend
limit_velocity=0.01; % minimum velocity to classify as head cast

limit_t=2; % time threshold in second to consider it as a bend
limit_ratio=0.4; % ratio of the event defined as static bend (multiplied by time spent), then consider whole action as static bend
limit_ratiomax=0.6; % maximum ratio accepted to classify as static bend

%% Scan actions for each larva

for numberlarva=1:numberoflarvae
    larvaname=['larva' num2str(numberlarva)]; % larva number during scan
    actionLarva.(larvaname).name=trx(numberlarva).numero_larva_num; % larva name in choreography
    actionLarva.(larvaname).t=trx(numberlarva).t; % time course
    actionLarva.(larvaname).dS=trx(numberlarva).S_deriv_smooth_5; % time course
    actionLarva.(larvaname).action=trx(numberlarva).global_state_large_state; % actions performed
    actionLarva.(larvaname).velocity=trx(numberlarva).motion_velocity_norm_smooth_5; % velocity
end

%% Detect and classify head cast and bend

for numberlarva=1:numberoflarvae
    larvaname=['larva' num2str(numberlarva)]; % larva number during scan
    bend=find(actionLarva.(larvaname).action==2); % find bending events
    
    if isempty(bend)==0 % if there are bends
        % find different bending events
        if successiveNumbers(bend)==0
            beginend = findSuccessiveNumbers(bend);
        else % if only one period of bend
            beginend=[bend(1) bend(end)];
        end
        repetitionofbend=size(beginend,1);
        
        % redefine the static bend VS head casting
        for repetition=1:repetitionofbend
            for indice=beginend(repetition,1):beginend(repetition,2)
                if abs(actionLarva.(larvaname).dS(indice))<limit_dS
                    actionLarva.(larvaname).action(indice)=9; % static bend
                end
            end
            
            % reclassify depending on other thresholds
            timeduration=actionLarva.(larvaname).t(beginend(repetition,2))-actionLarva.(larvaname).t(beginend(repetition,1));
            % if event long enough and if static bend in the middle, consider static bend
            if timeduration>=limit_t
                indextolookat=find(actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))==2);
                indextolookat2=find(actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))==9);
                if length(indextolookat2)/length(indextolookat)>min(limit_ratio*timeduration,limit_ratiomax)
                    actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))=9; % static bend
                end
            end
            
            % if event with non null velocity, consider head cast
            mean_velocity=mean(actionLarva.(larvaname).velocity(beginend(repetition,1):beginend(repetition,2)));
            if mean_velocity>=limit_velocity
                actionLarva.(larvaname).action(beginend(repetition,1):beginend(repetition,2))=2; % head cast
            end
            % if event begins and ends with head cast, still consider
%             % static bend
%             if
%             end
        end
    end
end

