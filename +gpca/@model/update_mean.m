function update_mean(obj)

    if isfinite(obj.nm0)
        obj.nm   = numel(obj.data) * obj.lam + obj.nm0;
        mu       = 0;
        data     = obj.data;
        obj.data = [];
        M        = obj.M;
        U        = obj.U;
        D        = prod(obj.lat);
        parfor(n=1:numel(data), obj.parallel)
            data1 = data(n);
            z     = read(data1.z);
            Uz    = 0;
            for m=1:M
                Um  = read(U, m);
                Uz  = Uz + z(m) * Um;
                Um  = [];
            end
            z     = [];
            x     = read(data1.x);
            mu    = mu + Uz - x;
            Uz    = [];
            x     = [];
            
        end
        obj.data = data;
        mu       = (lam * mu + obj.nk0 * obj.mu0)/obj.nk;
        obj.mu   = mu;
        if issame(mu,0)
            obj.trLM = 0;
        else
            obj.trLM = obj.dot.solve(mu);
            obj.trLM = obj.trLM(:)'*mu(:);
            if obj.nm0 > 0
                obj.trLM = obj.trLM + D/obj.nm;
            end
        end
        clear mu
    else
        obj.mu   = obj.mu0;
        obj.nm   = obj.nm0;
        mu       = read(obj.mu);
        if issame(mu,0)
            obj.trLM = 0;
        else
            obj.trLM = obj.dot.solve(mu);
            obj.trLM = obj.trLM(:)'*mu(:);
        end
        clear mu
    end
    
end