function [T, iT] = ortho_matrix(ZZ, ULU)
% FORMAT [T, iT] = ortho_matrix(ZZ,ULU)
%
% ** Input **
% ezz - E[ZZ']  = E[Z]E[Z]'   + inv(Az)
% ww  - E[U'LU] = E[U]'LE[U]' + inv(Au)
% ** Output **
% T   - Orthogonalisation matrix,  s.t.   T * ZZ  * T' ~ diag
% iT  - Almost inverse of T,       s.t. iT' * ULU * iT ~ diag


    [Vz, Dz2]  = svd(double(ZZ));
    [Vw, Dw2]  = svd(double(ULU));
    Dz         = diag(sqrt(diag(Dz2) + eps));
    Dw         = diag(sqrt(diag(Dw2) + eps));
    [U, D, V]  = svd(Dw * Vw' * Vz * Dz');
    Dz         = gpca.utils.loaddiag(Dz);
    Dw         = gpca.utils.loaddiag(Dw);
    T          = D * V' * (Dz \ Vz');
    iT         = Vw * (Dw \ U);
    
end