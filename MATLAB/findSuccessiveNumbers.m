function bool = findSuccessiveNumbers(q)
% Determines the indices of successive numbers in a matrix
a=diff(q);
fin=find(a>1);

d=length(fin); % number of sequences

if isempty(fin)==0
    
    % establish if the final sequence ends at the end
    if fin(end)~=length(q) % if not, it means that there is one more sequence
        d=length(fin)+1; % number of sequences
    % create table with beggining of sequences
        for i=1:d
            if i == 1
                debut(i)=1;
            else
                debut(i)=fin(i-1)+1;
            end
        end
        % add the last end which is the length of the initial table
        fin=[fin; length(q)];
    else
        d=length(fin); % number of sequences
        % create table with beggining of sequences
        for i=1:d
            if i == 1
                debut(i)=1;
            else
                debut(i)=fin(i-1)+1;
            end
        end
    end
        
end
% bool=[debut; fin];
bool=[q(debut) q(fin)]; % in the end, 1st column = beginings, 2nd = ends
end
