function figures=ethogram(adresse)
% Ethogram is a function that creates an ethogram from a trx.ma file

%% Initialize by extracting trx.mat file

dirtrx=[adresse '\trx.mat'];
load('-mat', dirtrx);

couleurs=[
    0    0    0
    1    0    0
    0    1    0
    0    0    1
    0    1    1
    1    1    0
    1    0    1
    0    0.4470    0.7410 % last color if redefine backup sequences
    ];

%% Set the structures containing data about actions
numberoflarvae=length(trx);
actionLarva=struct; % to store the action of the larva over time

%% Scan all actions performed by the larvae

for numberlarva=1:numberoflarvae
    larvaname=['larva' num2str(numberlarva)]; % larva number during scan
    actionLarva.(larvaname).name=trx(numberlarva).numero_larva; % larva name in choreography
    actionLarva.(larvaname).t=trx(numberlarva).t; % time course
    actionLarva.(larvaname).action=trx(numberlarva).global_state_large_state; % actions performed
end

%% Plot all actions in an ethogram

figures=figure;
hold on
for numberlarva=1:numberoflarvae
    larvaname=['larva' num2str(numberlarva)]; % larva number during scan
    y=numberlarva;
    for timestep=1:length(actionLarva.(larvaname).t)-1
        i=actionLarva.(larvaname).action(timestep);
        plot([actionLarva.(larvaname).t(timestep) actionLarva.(larvaname).t(timestep+1)],[y y],'linewidth',4,'color',couleurs(i,:));
    end
end

filename=[adresse '\ethogram'];
saveas(gcf,[filename '.fig']);
saveas(gcf,[filename '.png']);
end