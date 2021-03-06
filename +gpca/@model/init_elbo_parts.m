function obj = init_elbo_parts(obj)

        N = numel(obj.data);
        D = prod(obj.lat);

        % ----------
        % ELBO parts
        % ----------
        
        mu  = gpca.format.read(obj.mu);
        mu0 = gpca.format.read(obj.mu0);
        dot = obj.dot;
        U   = obj.U;
        M   = obj.M;
        D   = prod(obj.lat);
        
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
        parfor(n=1:N, obj.parallel)
%         for n=1:N
            data1 = data(n);
            % 4a) Reconstruct fit (U*z)
            z     = data1.z;
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
        
        
        % 5) Tr(E[]U'*L*U] * E[Z*Z'])
        obj.elbo_parts.trULUZZ = trace((obj.ULU+D*obj.iAu)*(obj.ZZ+N*obj.iAz));

end