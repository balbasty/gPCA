function update_latent_precision(obj)

    if isfinite(obj.nz0)
        obj.nz   = numel(obj.data) + obj.nz0;
        obj.Az   = (obj.ZZ + obj.nz0*obj.Az0)/obj.nz;
        
        if obj.nz0 == 0
            obj.logAz = gpca.utils.logdetPD(obj.Az);
        else
            obj.logAz = gpca.utils.logdetPD(obj.Az) ...
                        + gpca.utils.diGamma(0.5*obj.nz) ...
                        - obj.M * log(0.5*obj.nz);
        end
        
    else
        obj.Az    = obj.Az0;
        obj.nz    = obj.nz0;
        obj.logAz = gpca.utils.logdetPD(obj.Az);
    end
    
end