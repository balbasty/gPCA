function obj = apply_internal(obj)

    % ----------
    % Initialise
    % ----------

    obj.init_latent();
    obj.init_elbo_parts();
    
    obj.elbo_obs();
    obj.elbo_latent();
    obj.elbo_mean();
    obj.elbo_subspace();
    obj.elbo_latent_precision();
    obj.elbo_residual_precision();

    obj.plot();
    
    % --------
    % Optimise
    % --------
    
    i = 1;
    while true
        
        % -------------
        % Update latent
        % -------------
        obj.update_all_subjects();
        obj.elbo_obs();
        obj.elbo_latent();
        
        obj.plot();
        
        % ------------
        % Compute ELBO
        % ------------
        elbo = obj.lbX + obj.lbZ + obj.lbU + obj.lbm + ubj.lbA + obj.lbl;
        obj.elbo(end+1) = elbo;
        obj.gain = abs(obj.elbo(end) - obj.elbo(end-1))/(max(obj.elbo)-min(obj.elbo));
        
        if i >= obj.iter_max
            break
        end
        if i >= obj.iter_min
            if obj.gain < obj.tolerance
                break
            end
        end
        i = i + 1;
        
    end
    
end