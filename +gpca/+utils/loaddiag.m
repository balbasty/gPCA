function A = loaddiag(A)
% FORMAT A = gpca.utils.loaddiag(A)
% A  - A square matrix
%
% Load A's diagonal until it is well conditioned for inversion.

    factor = 1e-7;
    while rcond(A) < 1e-5
        A = A + factor * max([diag(A); eps]) * eye(size(A));
        factor = 10 * factor;
    end

end
