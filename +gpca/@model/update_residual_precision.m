function obj = update_residual_precision(obj)


    if isfinite(obj.nl0)
    % ---------------------------------------------------------------------
    % Maximum likelihood (nl0 == 0) or Variational posterior (nl0 > 0)
    % ---------------------------------------------------------------------
    
        % ----------------
        % Useful variables
        % ----------------
        N        = numel(obj.data);
        D        = prod(obj.lat);
    
        % ------------------
        % degrees of freedom
        % ------------------
        % > n = n0 + N
        obj.nl   = obj.nl0 + N;
        
        % ------------------
        % maximum-likelihood
        % ------------------
        % > inv(ML[lam]) = (1/ND) * ( N*var[Tr(L*mu*mu')]
        %                             + Tr(L*(X-mu)*(X-mu)')
        %                             + Tr(E[U'*L*U]*E[Z*Z'])
        %                             - 2*Tr(L*U*Z*(X-mu)) )
        lam      =   N * obj.elbo_parts.varLM...
                   +     obj.elbo_parts.trLS ...
                   +     obj.elbo_parts.trULUZZ ...
                   - 2 * obj.elbo_parts.trLUZX;
        lam      = lam/D;
        
        % ----------------
        % Variational mean
        % ----------------
        % > inv(E[lam]) = (n0 * inv(lam0) + N * inv(ML[lam])) / (n0 + N)
        if obj.nl0 > 0
            lam = lam + obj.nl0 * 1/obj.lam0;
        end
        lam      = lam/obj.nl;
        obj.lam  = 1/lam;
        
        % ----------------
        % Expected log det
        % ----------------
        obj.loglam = log(obj.lam);
        if obj.nl0 > 0
            obj.loglam = obj.loglam ...
                         + gpca.utils.diGamma(0.5*obj.nl*D) ...
                         - log(0.5*obj.nl*D);
        end
        
    else
    % ---------------------------------------------------------------------
    % Fixed value (nl0 == inf)
    % ---------------------------------------------------------------------
        % Nothing to do
    end
    
end