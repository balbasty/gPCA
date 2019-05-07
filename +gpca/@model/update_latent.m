function obj = update_latent(obj)

    N = numel(obj.data);
    D = prod(obj.lat);

    % ----------------------------------
    % precision (common across subjects)
    % ----------------------------------
    % Common to all subjects so we pre-compute the value
    % > Az = A + lam * (U'*L*U + inv(Au))
    obj.Az  = obj.A + obj.lam * (obj.ULU + D * obj.iAu);
    obj.iAz = gpca.utils.invPD(obj.Az);

    % ----
    % mean
    % ----
    Z        = zeros(obj.M,numel(obj.data));
    ZZ       = zeros(obj.M);
    
    [data, obj.data] = deal(obj.data, []);
    parfor(n=1:N, obj.parallel)
%     for n=1:N
        
        data(n) = obj.update_latent_one(data(n));
        Z(:,n)  = data(n).z;
        ZZ      = ZZ + data(n).zz;
        
    end
    obj.data = data; clear data
    
    obj.Z    = Z;
    obj.ZZ   = ZZ;
    obj.elbo_parts.trULUZZ = trace((obj.ULU + D*obj.iAu)*(obj.ZZ + N*obj.iAz));
   
    
    % ----------
    % ELBO parts
    % ----------
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
    
    obj.Z_iscentred = false;
end