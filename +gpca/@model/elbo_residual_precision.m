function obj = elbo_residual_precision(obj)

    D = prod(obj.lat);

    if ~isfinite(obj.nl0) || obj.nl0 == 0
        obj.lbl = 0;
    else
        obj.lbl =   0.5 * D * obj.nl0 * log((obj.lam/obj.nl)/(obj.lam0/obj.nl0)) ...
                  + 0.5 * D * obj.nl * (1 - (obj.lam/obj.nl)/(obj.lam0/obj.nl0)) ...
                  - gpca.utils.logGamma(0.5*obj.nl0*D) ...
                  + gpca.utils.logGamma(0.5*obj.nl*D) ...
                  - 0.5 * D * (obj.nl-obj.nl0) * gpca.utils.diGamma(0.5*obj.nl*D);
    end

end