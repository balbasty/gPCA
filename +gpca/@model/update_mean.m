function obj = update_mean(obj)

    if isfinite(obj.nm0)
    % ---------------------------------------------------------------------
    % Maximum likelihood (nm0 == 0) or Variational posterior (nm0 > 0)
    % ---------------------------------------------------------------------
        
        % ----------------
        % Useful variables
        % ----------------
        M   = obj.M;              % Latent dimension
        D   = prod(obj.lat);      % Observed dimension
        U   = obj.U;              % E[] Subspace
        dot = obj.dot;            % Dot product
        
        % ------------------
        % degrees of freedom
        % ------------------
        % > n = n0 + N * lam
        obj.nm   = obj.nm0 + numel(obj.data) * obj.lam;
        
        % ------------------
        % Maximum likelihood
        % ------------------
        % > ML[mu] = mean{x - Uz}
        mu = 0;
        Z_iscentred = obj.Z_iscentred;
        [data, obj.data] = deal(obj.data, []);
        parfor(n=1:numel(data), obj.parallel)
            % 1) Reconstruct fit (U*z)
            data1 = data(n);
            Uz    = 0;
            if ~Z_iscentred
                z     = data1.z;
                for m=1:M
                    Um  = gpca.format.read(U, m);
                    Uz  = Uz + z(m) * Um;
                    Um  = [];
                end
                z     = [];
            end
            % 2) Add difference mu += (x - Uz)
            mu    = mu + (gpca.format.read(data1.x) - Uz);
            Uz    = [];
            data1 = [];
            
        end
        obj.data = data; clear data
        
        % ----------------
        % Variational mean
        % ----------------
        % > E[mu] = (n0 * mu0 + N * lam * ML[mu]) / (n0 + lam * N)
        mu0      = gpca.format.read(obj.mu0);
        mu       = (obj.lam * mu + obj.nm0 * mu0)/obj.nm;
        obj.mu   = gpca.format.write(obj.mu,mu);
        
        % ----------
        % ELBO parts
        % ----------
        
        % 1) Tr(L*(mu-mu0)*(mu-mu0'))
        diff_mu   = mu-mu0; clear mu0
        L_diff_mu = obj.dot.solve(diff_mu);
        obj.elbo_parts.trLM = double(diff_mu(:))'*double(L_diff_mu(:));
        clear diff_mu L_diff_mu
        
        % 2) Uncty[Tr(L*mu*mu')]
        if obj.nm0 > 0
            obj.elbo_parts.varLM = D/obj.nm;
        else
            obj.elbo_parts.varLM = 0;
        end
        
        % 3) Tr(L*(X-mu)*(X-mu)')
        % 4) Tr(L*U*Z*(X-mu)')
        trLS = 0;
        trLUZX = 0;
        [data, obj.data] = deal(obj.data, []);
        parfor(n=1:numel(data), obj.parallel)
            data1 = data(n);
            % 4a) Reconstruct fit (U*z)
            z     = data1.z
            Uz    = 0;
            for m=1:M
                Um  = gpca.format.read(U, m);
                Uz  = Uz + z(m) * Um;
                Um  = [];
            end
            z     = [];
            % 3a) Compute x- mu
            x     = gpca.format.read(data1.x) - mu;
            data1 = [];
            % 3-4b) Compute L * (x- mu)
            Lx = dot.solve(x);
            % 3c) Accumulate
            trLS = trLS + double(x(:))' * double(Lx(:));
            x    = [];
            % 4c) Accumulate
            trLUZX = trLUZX + double(Uz(:))' * double(Lx(:));
            
            Lx = [];
            Uz = [];
        end
        obj.data = data; clear data
        obj.elbo_parts.trLS   = trLS;
        obj.elbo_parts.trLUZX = trLUZX;
        clear mu
        
        
    else
    % ---------------------------------------------------------------------
    % Fixed value (nm0 == inf)
    % ---------------------------------------------------------------------
        % Nothing to do
    end
    
end