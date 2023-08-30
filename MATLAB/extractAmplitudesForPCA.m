%% For PCA for bend and cast

timewindows=[60 90];
trx=TRX.Fed;
numberoflarvae=length(trx);

actiontowrite=1;
for numberlarva=1:numberoflarvae
    larvaname=['larva' num2str(numberlarva)];
    transit=find(trx(numberlarva).t>=timewindows(1,1)&trx(numberlarva).t<=timewindows(1,2));
    
    if isempty(transit)==0
        
        indexofinterest=[min(transit) max(transit)];
        times_loc=trx(numberlarva).t(indexofinterest(1):indexofinterest(2));
        actionLarva_loc=trx(numberlarva).global_state_large_state(indexofinterest(1):indexofinterest(2));
        length_loc=trx(numberlarva).larva_length_smooth_5(indexofinterest(1):indexofinterest(2));
        deriv_length_loc=trx(numberlarva).larva_length_deriv_smooth_5(indexofinterest(1):indexofinterest(2));
        S_loc=trx(numberlarva).S_smooth_5(indexofinterest(1):indexofinterest(2));
        S_deriv_loc=trx(numberlarva).S_deriv_smooth_5(indexofinterest(1):indexofinterest(2));
        velocity_loc=trx(numberlarva).motion_velocity_norm_smooth_5(indexofinterest(1):indexofinterest(2));
        x_center_loc=trx(numberlarva).x_center(indexofinterest(1):indexofinterest(2));
        y_center_loc=trx(numberlarva).y_center(indexofinterest(1):indexofinterest(2));
        head_velocity_loc=trx(numberlarva).head_velocity_norm_smooth_5(indexofinterest(1):indexofinterest(2));
        
        % Measure parameters for all actions
        for actiontolook=[2 9] % bend or cast
            timesforaction=find(actionLarva_loc==actiontolook);
            if isempty(timesforaction)==0 % if indeed the larva peformed the action during that time window
                if successiveNumbers(timesforaction)==0 % if several periods of runs
                    beginend = findSuccessiveNumbers(timesforaction); % table that contains one line for begining the time sequence of this action, and one line for the end
                else % if only one period of run
                    beginend=[timesforaction(1) timesforaction(end)];
                end
                repetitionofaction=size(beginend,1);
                
                for actioncount=1:repetitionofaction
                    actiontype(actiontowrite,1)=actionLarva_loc(beginend(actioncount,1));
                    velocitybend(actiontowrite,1)=mean(velocity_loc(beginend(actioncount,1):beginend(actioncount,2)));
                    headvelocitybend(actiontowrite,1)=mean(head_velocity_loc(beginend(actioncount,1):beginend(actioncount,2)));
                    Sbend(actiontowrite,1)=mean(S_loc(beginend(actioncount,1):beginend(actioncount,2)));
                    dSbend(actiontowrite,1)=mean(S_deriv_loc(beginend(actioncount,1):beginend(actioncount,2)));
                    lengthbend(actiontowrite,1)=mean(length_loc(beginend(actioncount,1):beginend(actioncount,2)));
                    dlengthbend(actiontowrite,1)=mean(deriv_length_loc(beginend(actioncount,1):beginend(actioncount,2)));
                    timebend(actiontowrite,1)=times_loc(beginend(actioncount,2))-times_loc(beginend(actioncount,1));
                    actiontowrite=actiontowrite+1;
                end
            end
        end
    end
end

dataforPCA2=[actiontype velocitybend headvelocitybend Sbend dSbend lengthbend dlengthbend];