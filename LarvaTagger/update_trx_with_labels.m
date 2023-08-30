function [updated_trx] = update_trx_with_labels(trx, label_file, varargin)
% UPDATE_TRX_WITH_LABELS  Update trx structure array with json labels.
%
%   TRX = UPDATE_TRX_WITH_LABELS(TRX, LABEL_FILE) loads json-encoded
%     labels from file LABEL_FILE, and add corresponding fields in
%     structure array TRX.
%
%   TRX = UPDATE_TRX_WITH_LABELS(TRX_FILE, LABEL_FILE) loads TRX from file
%     TRX_FILE.
%
%   TRX = UPDATE_TRX_WITH_LABELS(..., "outputfile", OUTPUT_TRX_FILE) saves
%     the updated TRX to file OUTPUT_TRX_FILE.
%
%   TRX = UPDATE_TRX_WITH_LABELS(..., "removetags", 1) resets all known
%     tags from TRX prior to adding tags from LABEL_FILE.
%
%   TRX = UPDATE_TRX_WITH_LABELS(..., "labels", LABEL_OVERRIDES) overrides
%     the tags defined in file LABEL_FILE with cell array LABEL_OVERRIDES.
%     LABEL_OVERRIDES can list labels as either individual strings, to
%     explicitly include these labels without mapping, or 2-element cell
%     arrays such that the first element is to be found in LABEL_FILE and
%     the second element refers to a field in TRX. Labels that are not
%     listed are ignored.
%
%   See also RESET_BEHAVIOR_TAGS.

if ~isa(trx, "struct")
    load(trx, "trx");
end

args = struct();
if 2<nargin
    for n = 3:2:nargin
        args.(varargin{n-2}) = varargin{n-1};
    end
end

if isfield(args, "removetags")
    if args.removetags
        trx = reset_behavior_tags(trx);
    end
end

data = jsondecode(fileread(label_file));
labels = data.labels;
if isa(labels, "struct")
    labels = labels.names;
end

updated_trx = struct([]);
% backward indexing trick to preallocate the updated_trx array
for k = length(trx):-1:1
    for f = fieldnames(trx)'
        f = f{1};
        updated_trx(k,1).(f) = trx(k).(f);
    end
    tag = -ones(size(trx(k).t));
    for label = labels'
        label = map_label(args, label{1});
        updated_trx(k,1).(label) = tag;
    end
end

data = data.data;
for larva_index = 1:length(data)
    assigned_labels = data(larva_index).labels;
    larvaid = data(larva_index).id;
    larva = find([trx.numero_larva_num]==str2num(larvaid));
    if isempty(larva)
        disp("skipping larva " + larvaid);
    else
    for label_index = 1:length(labels)
        label = map_label(args, labels{label_index});
        field = updated_trx(larva).(label);
        field(where_label(assigned_labels, label_index)) = 1;
        updated_trx(larva).(label) = field;
    end
    end
end

if isfield(args, "outputfile")
    trx = updated_trx;
    save(args.outputfile, "trx", "-v7.3");
end

function label = map_label(args, label)
    if isfield(args, "labels")
        for i = 1:numel(args.labels)
            mapping = args.labels{i};
            if iscell(mapping)
                if strcmp(mapping{1}, label)
                    label = mapping{2};
                    break
                end
            elseif strcmp(mapping, label)
                break
            end
        end
    end
end

function ret = where_label(labels, label)
    if iscell(labels)
        ret = zeros(size(labels), 'logical');
        for i = 1:length(labels)
            ret(i) = any(labels{i}==label);
        end
    else
        ret = labels == label;
    end
end

end
