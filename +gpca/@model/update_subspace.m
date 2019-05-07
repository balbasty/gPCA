function obj = update_subspace(obj)

    N = numel(obj.data);
    D = prod(obj.lat);

    % ---------
    % precision
    % ---------
    % > Au = lam * E[Z*Z'] + I
    obj.Au   = eye(obj.M) + obj.lam * (obj.ZZ + N * obj.iAz);
    obj.iAu  = gpca.utils.invPD(obj.Au);
    
    % ----------------
    % variational mean
    % ----------------
    % > E[U] = lam * (X - mu) * Z' * inv(Au)
    
    % 1) Compute lam * Z' * inv(Au)
    ZiA      = obj.lam * obj.Z' * obj.iAu;
    
    % 2) Compute (X - mu) * [lam * Z' * inv(Au)]
    mu = double(gpca.format.read(obj.mu));
    [data, obj.data] = deal(obj.data, []);
    for m=1:obj.M
        Um       = 0;
        parfor(n=1:N, obj.parallel)
            data1 = data(n);
            x     = double(gpca.format.read(data1.x));
            data1 = [];
            Um    = Um + (x - mu) * ZiA(n,m);
            x     = [];
        end
        obj.U = gpca.format.write(obj.U, Um, m);
        clear UM
    end
    obj.data = data;
    
    % ----------
    % U' * L * U
    % ----------
    
    ULU = zeros(obj.M);
    for m=1:obj.M
        Um       = gpca.format.read(obj.U, m);
        LUm      = obj.dot.solve(Um);
        ULU(m,m) = double(LUm(:))' * double(Um(:));
        clear Um
        for p=(m+1):obj.M
            Up       = gpca.format.read(obj.U, p);
            ULU(m,p) = double(LUm(:))' * double(Up(:));
            ULU(p,m) = ULU(m,p);
            clear Up
        end
        clear LUm
    end
    obj.ULU  = ULU;
    obj.elbo_parts.trULUZZ = trace((obj.ULU + D*obj.iAu)*(obj.ZZ + N*obj.iAz));
    

    % ----------
    % ELBO parts
    % ----------
    % Tr(L*U*Z*(X-mu)')
    dot = obj.dot;
    U   = obj.U;
    M   = obj.M;
    
    trLUZX = 0;
    [data, obj.data] = deal(obj.data, []);
    parfor(n=1:N, obj.parallel)
%     for n=1:N
        data1 = data(n);
        % a) Reconstruct fit (U*z)
        z     = data1.z;
        Uz    = 0;
        for m=1:M
            Um  = double(gpca.format.read(U, m));
            Uz  = Uz + z(m) * Um;
            Um  = [];
        end
        z     = [];
        % b) Compute L * (x- mu)
        Lx = double(gpca.format.read(data1.x)) - mu;
        Lx = dot.solve(Lx);
        data1 = [];
        % c) Accumulate
        trLUZX = trLUZX + double(Uz(:))' * double(Lx(:));

        Lx = [];
        Uz = [];
    end
    obj.data = data; clear data
    obj.elbo_parts.trLUZX = trLUZX;
    clear mu
end