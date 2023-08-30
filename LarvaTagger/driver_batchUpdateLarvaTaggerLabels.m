%% Batch update trx files with predicted labels from LarvaTagger
rootdir = '/Volumes/TOSHIBA/t2';
trxlist = dir(fullfile(rootdir, '**/trx.mat'))
labellist = dir(fullfile(rootdir, '**/predicted.label'))

actionnames = ["run_large"
        "cast_large"
        "stop_large"
        "hunch_large"
        "back_large"
        "roll_large"]

for i = 1:length(trxlist)
    % first update the binary labels 
    trx = update_trx_with_labels(strcat(trxlist(i).folder,'/',trxlist(i).name),...
        strcat(labellist(i).folder,'/',labellist(i).name));
    % update the field global state for downstream analysis
    for l = 1:length(trx) % for each larva within the trx file
        for n = 1:length(actionnames) % for each possible action
            indices = find(trx(l).(actionnames(n)) == 1); % find the time stamps when larva is in that state
            trx(l).global_state_large_state(indices) = n; % assign the state to field global state
        end
    end
    filename = strcat(labellist(i).folder,'/updated_trx.mat');
    save(filename,'trx','-v7.3');
    disp(i)
end