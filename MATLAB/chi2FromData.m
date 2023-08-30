function pval=chi2FromData(p1,p2,N1,N2)
% chi2FromData gives the p value of chi2 exact test

n1=int16(N1*p1); % number of larvae performing the action in population 1
n2=int16(N2*p2); % number of larvae performing the action in population 2
[x1] = [repmat('a',N1,1); repmat('b',N2,1)];
[x2] = [repmat(1,n1,1); repmat(2,N1-n1,1); repmat(1,n2,1); repmat(2,N2-n2,1)];
[tbl, chi2stat, pval] = crosstab(x1,x2);

end