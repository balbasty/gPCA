function [Q, iQ, q] = gn_scale_U(EUU, EZZ, A0, nA0, N, D, q0)
% FORMAT [Q, iQ] = gn_scale_U(EUU, EZZ, A0, nA0, N, D, q0)
% ww  - W'LW
%       > Must have been orthogonalised before.
% zz  - Z*Z'
%       > Must have been orthogonalised before.
% Sz  - cov[Z]
%       > Must have been orthogonalised before.
% n0  - Number of degrees of freedom of the Wishart prior
% N   - Number of observations
%
% Gauss-Newton optimisation of the scaling factor between LW and Z
    M = size(EZZ, 1);

    if nargin < 9 || isempty(q0)
        q0    = zeros(M,1)-0.5*log(D);
    end

    q    = min(max(q0,-10),10);  % Heuristic to avoid bad starting estimate
    Q    = diag(exp(q));
    A    = wishart_update(Q*EZZ*Q, N, A0, nA0);
    E    = 0.5*(trace(Q*EZZ*Q*A) + trace(EUU/(Q*Q))) ...
            + (D - N) * gpca.utils.logdetPD(Q);
    % fprintf('[%3d %2d] %15.6g',0,0,E)

    all_E0 = E;
    for iter=1:100
        A   = wishart_update(Q*EZZ*Q, N, A0, nA0);
        oE0 = E;

        all_E = E;
        for subit=1:10
            R  = A.*EZZ'+A'.*EZZ;
            g1 = Q*R*diag(Q);
            g2 =-2*(Q^2\diag(EUU));
            g  = g1 + g2 + 2 * (D - N);

            H1 = Q*R*Q + diag(g1);
            H2 = 4*(Q^2\EUU);
            H  = H1+H2;

            H  = gpca.utils.loaddiag(H);
            q  = q - H\g;
            q  = min(max(q,-10),10); % Heuristic to avoid overshoot
            Q  = diag(exp(q));

            oE = E;
            E  = 0.5*(trace(Q*EZZ*Q*A) + trace(EUU/(Q*Q))) ...
                  + (D - N) * gpca.utils.logdetPD(Q);
            all_E = [all_E E];

            % fprintf('\n[%3d %2d] %15.6g (%8.1e)',iter,subit,E, ...
            %     abs(oE-E)/(max(all_E)-min(all_E)+eps))
            if abs(oE-E)/(max(all_E)-min(all_E)+eps) < 1e-8, break; end
        end
        all_E0 = [all_E0 E];
        % fprintf(' (%8.1e)', abs(oE0-E)/(max(all_E0)-min(all_E0)+eps))
        if abs(oE0-E)/(max(all_E0)-min(all_E0)+eps) < 1e-20, break; end
    end
    iQ = inv(Q);
    % fprintf('\n');
end
   
function A = wishart_update(EZZ, N, A0, nA0)
    if ~isfinite(nA0)
        A = A0;
    else
        A = EZZ;
        if nA0 > 0
            A = A + nA0 * gpca.utils.invPD(A0);
        end
        A = A / (nA0 + N);
        A = gpca.utils.invPD(A);
    end
end

% % Code for working out the gradients and Hessians
% q   = sym('q',[3,1],'real');
% Q   = diag(exp(q));
% % A   = diag(sym('a',[3,1],'real'));
% % ZZ  = diag(sym('z',[3,1],'real'));
% % WW   = diag(sym('w',[3,1],'real'));
% A   = sym('a',[3,3],'real');
% ZZ  = sym('z',[3,3],'real');
% WW   = sym('w',[3,3],'real');
% DmN = sym('DmN','real');
% %%
% E   = trace(Q*ZZ*Q*A) + trace(WW*inv(Q*Q)) + 2 * DmN * log(det(Q));
% %%
% pretty(simplify(diff(E,sym('q1')),1000))
% pretty(simplify(diff(diff(E,sym('q1')),sym('q2')),1000))
% pretty(simplify(diff(diff(E,sym('q1')),sym('q1')),1000))
% %%
% g1 =  Q*(A.*ZZ'+A'.*ZZ)*diag(Q);
% g2 = -Q^2\diag(WW)*2;
% g  =  g1+g2+2*DmN;
% H1 =  Q*(A'.*ZZ + A.*ZZ')*Q +diag(g1);
% H2 =  4*WW*Q^(-2);
% H  =  H1+H2;
% %%
% d1  = simplify(g(1)  -diff(E,sym('q1')),1000)
% d11 = simplify(H(1,1)-diff(diff(E,sym('q1')),sym('q1')),1000)
