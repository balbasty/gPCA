function A = invPD(A)
% FORMAT iA = gpca.utils.invPD(A)
% A  - A positive-definite square matrix
% iA - Its inverse
%
% Stable inverse of a positive-definite matrix.
% Eigendecomposition is used to compute a more stable inverse.

% John Ashburner

    [V,D] = eig(A);
    if any(diag(D) <= 0)
        warning('Matrix has negative eigenvalues')
        D(D <= 0) = eps; % Threshold negative eigenvalues
    end
    D     = loaddiag(D);
    A     = real(V * (D \ V'));

end