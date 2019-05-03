function obj = elbo_mean(obj)

    if ~isfinite(obj.nm0) || obj.nm0 == 0
        obj.lbm = 0;
    else
        D = prod(obj.lat);

        obj.lbm =   obj.nm0/D * obj.elbo_parts.trLM ...
                  + obj.nm0/obj.nm ...
                  + log(obj.nm/obj.nm0) ...
                  - 1;
       obj.lbm = - 0.5 * D * obj.lbm;
    end

end