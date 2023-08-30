function figures=ethogramFromTrx(trx)
% Ethogram is a function that creates an ethogram from a trx.ma file

%% Initialize by extracting trx.mat file

couleurs=[
    0    0    0
    1    0    0
    0    1    0
    0    0    1
    0    1    1
    1    1    0
    1    0    1
    0    0.4470    0.7410 % last color if redefine backup sequences
    0.8500    0.3250    0.0980 % head castin
    0.9290    0.6940    0.1250 % static bend
    ];

%% Set the structure containing data about actions

numberoflarvae=100;
%if numberoflarvae>100 % if too many larvae, will not easily be ploted
    %figures=0;
    %return; % so break the function
%end
actionLarva=struct; % to store the action of the larva over time

%% Scan all actions performed by the larvae

for numberlarva=1:numberoflarvae
    larvaname=['larva' num2str(numberlarva)]; % larva number during scan
%     actionLarva.(larvaname).name=trx(numberlarva).numero_larva; % larva name in choreography
    actionLarva.(larvaname).t=trx(numberlarva).t; % time course
    actionLarva.(larvaname).action=trx(numberlarva).global_state_large_state; % actions performed
end

%% Plot all actions in an ethogram

figures=figure('Renderer', 'painters', 'Position', [10 10 700 700]);
hold on
for numberlarva=1:numberoflarvae
    larvaname=['larva' num2str(numberlarva)]; % larva number during scan
    y=numberlarva;
    dim=700/numberoflarvae-2;
    for timestep=1:length(actionLarva.(larvaname).t)-1
        i=actionLarva.(larvaname).action(timestep);
        plot([actionLarva.(larvaname).t(timestep) actionLarva.(larvaname).t(timestep+1)],[y*dim y*dim],'linewidth',dim,'color',couleurs(i,:));
    end
end
xlabel('Time (s)');
title(['Ethogram n=' num2str(numberlarva)]);
end