function obj = init_model(obj)
    
    D = prod(obj.lat);

    % ----
    % mean
    % ----
    format = gpca.format.auto(obj.mu0);
    if ~isfinite(obj.nm0)
        obj.mu = obj.mu0;
    else
        if format.numel(obj.mu0) == 1
            obj.mu = obj.format.allocate(obj.lat);
            obj.mu = obj.format.write(obj.mu, format.read(obj.mu0));
        else
            obj.mu = format.like(obj.mu0, 'mean');
            obj.mu = format.write(obj.mu, format.read(obj.mu0));
        end
    end
    obj.nm = obj.nm0;
    mu = gpca.format.read(obj.mu);
    clear mu
    
    
    % ------------------
    % residual precision
    % ------------------
    obj.lam = obj.lam0;
    obj.nl  = obj.nl0;
    if ~isfinite(obj.nl) || obj.nl == 0
        obj.loglam = log(obj.lam);
    else
        obj.loglam = log(obj.lam) ...
                     + gpca.utils.diGamma(0.5*obj.nl*D) ...
                     - log(0.5*obj.nl*D);
    end
    
    % --------
    % subspace
    % --------
    obj.Au  = eye(obj.M);
    obj.iAu = gpca.utils.invPD(obj.Au);
    format = gpca.format.auto(obj.U0);
    obj.U  = obj.format.allocate([obj.lat obj.M], 'subspace');
    for m=1:obj.M
        obj.U = obj.format.write(obj.U, format.read(obj.U0, m), m);
    end
    obj.ULU = 0;
    for m=1:obj.M
        Um      = obj.format.read(obj.U, m);
        LUm     = obj.dot.solve(Um);
        obj.ULU = obj.ULU + LUm(:)' * Um(:);
        clear LUM
        clear Um
    end
    obj.ULU = obj.ULU;
    
    % ----------------
    % latent precision
    % ----------------
    if numel(obj.A0) == 1
        obj.A0 = repmat(obj.A0, [1 obj.M]);
    end
    if size(obj.A0,1) == 1 || size(obj.A0,2) == 1
        obj.A0 = diag(obj.A0);
    end
    if ~issame(size(obj.A0), [obj.M obj.M])
        error('Precision matrix must be of size M')
    end
    obj.A  = obj.A0;
    obj.nA = obj.nA0;
    obj.logA = gpca.utils.logdetPD(obj.A);
    if obj.nA0 > 0
        obj.logA = obj.logA ...
                    + gpca.utils.diGamma(0.5*obj.nA, obj.M) ...
                    - obj.M * log(obj.nA) ...
                    + obj.M * log(2);
    end

end