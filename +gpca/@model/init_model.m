function init_model(obj)
    
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
    
    % ----------------
    % latent precision
    % ----------------
    obj.lam = obj.lam0;
    obj.nl  = obj.nl0;
    
    % --------
    % subspace
    % --------
    format = gpca.format.auto(obj.U0);
    obj.U  = obj.format.allocate([obj.lat obj.M], 'subspace');
    for m=1:obj.M
        obj.U = obj.format.write(obj.U, format.read(obj.U, m), m);
    end
    
    % ------------------
    % residual precision
    % ------------------
    if numel(obj.Az0) == 1
        obj.Az0 = repmat(obj.Az0, [1 obj.M]);
    end
    if size(obj.Az0,1) == 1 || size(obj.Az0,2) == 1
        obj.Az0 = diag(obj.Az0);
    end
    if ~issame(size(obj.Az0), [obj.M obj.M])
        error('Precision matrix must be of size M')
    end
    obj.Az = obj.Az0;
    obj.nz = obj.nz0;

end