function obj = centre_latent(obj)

    N   = numel(obj.data);
    D   = prod(obj.lat);
    
    % ---------------------------------------------------------------------
    % Centre
    z0 = sum(obj.Z,2)/N;
    obj.Z  = bsxfun(@minus, obj.Z, z0);
    obj.ZZ = obj.ZZ - N * (z0 * z0');
    
    % ---------------------------------------------------------------------
    % Centre subjects
    Z  = obj.Z;
    [data, obj.data] = deal(obj.data, []);
    parfor(n=1:numel(data), obj.parallel)
        data1    = data(n);
        data1.z  = Z(:,n);
        data1.zz = data1.z(:) * data1.z(:)';
        data(n)  = data1;
    end
    obj.data = data; clear data
    obj.Z_iscentred = true;
    
    
   
    % ---------------------------------------------------------------------
    % ELBO parts
    
    % -------------
    % Tr([ULU][ZZ])
    obj.elbo_parts.trULUZZ = trace((obj.ULU + D*obj.iAu)*(obj.ZZ + N*obj.iAz));
    
    % -----------------
    % Tr(L*U*Z*(X-mu)')
    
    U   = obj.U;
    dot = obj.dot;
    M   = obj.M;
    
    trLUZX = 0;
    mu     = gpca.format.read(obj.mu);
    [data, obj.data] = deal(obj.data, []);
    parfor(n=1:N, obj.parallel)
        data1 = data(n);
        % a) Reconstruct fit (U*z)
        z     = data1.z
        Uz    = 0;
        for m=1:M
            Um  = gpca.format.read(U, m);
            Uz  = Uz + z(m) * Um;
            Um  = [];
        end
        z     = [];
        % b) Compute L * (x- mu)
        Lx = gpca.format.read(data1.x) - mu;
        Lx = dot.solve(Lx);
        % c) Accumulate
        trLUZX = trLUZX + double(Uz(:))' * double(Lx(:));

        Lx = [];
        Uz = [];
        data1 = [];
    end
    obj.data = data; clear data
    obj.elbo_parts.trLUZX = trLUZX;
    clear mu
end