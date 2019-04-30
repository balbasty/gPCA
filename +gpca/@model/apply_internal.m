function apply_internal(obj)

    % ----------
    % Initialise
    % ----------

    obj.init_latent();
    
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
        
        % ------------
        % Compute ELBO
        % ------------
        elbo = obj.lbX + obj.lbZ + obj.lbU + obj.lbm + ubj.lbAz + obj.lbl;
        obj.elbo(end+1) = elbo;
        gain = abs(obj.elbo(end) - obj.elbo(end-1))/(max(obj.elbo)-min(obj.elbo));
        
        if i >= obj.iter_max
            break
        end
        if i >= obj.iter_min
            if gain < tolerance
                break
            end
        end
        i = i + 1;
        
    end
    
end