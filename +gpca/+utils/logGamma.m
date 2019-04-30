function lg = logGamma(a, p)
    if nargin < 2
        p = 1;
    end
    lg = (p*(p-1)/4)*log(pi);
    for i=1:p
        lg = lg + gammaln(a + (1-p)/2);
    end
end