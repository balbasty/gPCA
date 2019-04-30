function elbo_mean(obj)

    if ~isfinite(obj.nm0) || obj.nm0 == 0
        obj.lbm = 0;
    else
        diff_mu  = read(obj.mu) - read(obj.mu0);
        D   = prod(obj.lat);
        
        if all(diff_mu(:) == 0)
            obj.lbm = 0.5 * D * (log(obj.nm0/obj.nm) +1 - obj.nm0/obj.nm);
        else
            L_diff_mu = obj.dot.solve(diff_mu);
            diff_mu = diff_mu(:)' * L_diff_mu(:);
            clear L_diff_mu
            obj.lbm =  0.5 * D * (log(obj.nm0/obj.nm) +1 - obj.nm0/obj.nm) ...
                      -0.5 * obj.nm0 * diff_mu;
        end
        
    end

end