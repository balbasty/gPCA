function dg = diGamma(a, p, k)
    if nargin < 3
        k = 0;
        if nargin < 2
            p = 1;
        end
    end
    dg = 0;
    for i=1:p
        dg = dg + psi(k, a + (1-i)/2);
    end
end