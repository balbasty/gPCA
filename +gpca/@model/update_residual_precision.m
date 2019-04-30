function update_residual_precision(obj)

    if isfinite(obj.nl0)
        obj.nl   = numel(obj.data) + obj.nl0;
        lam      = obj.trLS + trace(obj.ZZ*obj.ULU);
        mu       = read(obj.mu);
        data     = obj.data;
        obj.data = [];
        dot      = obj.dot;
        M        = obj.M;
        U        = obj.U;
        D        = prod(obj.lat);
        parfor(n=1:numel(data), obj.parallel)
            data1 = data(n);
            x     = read(data1.x);
            z     = read(data1.z);
            x     = dot.solve(x-mu);
            for m=1:M
                Um  = read(U, m);
                lam = lam -2 * z(m) * x(:)' * Um(:);
            end
        end
        obj.data = data;
        lam      = (lam + obj.nl0 * obj.lam0)/obj.nl;
        obj.lam  = lam;
        
        
        if obj.nl0 == 0
            obj.loglam = gpca.utils.log(obj.lam);
        else
            obj.loglam = gpca.utils.log(obj.lam) ...
                         + gpca.utils.diGamma(0.5*obj.nl*D) ...
                         - log(0.5*obj.nl*D);
        end
    else
        obj.lam    = obj.lam0;
        obj.nl     = obj.nl0;
        obj.loglam = gpca.utils.log(obj.lam);
    end
    
end