function obj = train_internal(obj)

    % ----------
    % Initialise
    % ----------

    obj.init_model();
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
       
        % ------------
        % Update model
        % ------------
        obj.update_model();
        
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
        elbo = obj.lbX + obj.lbZ + obj.lbU + obj.lbm + obj.lbA + obj.lbl;
        obj.elbo(end+1) = elbo;
        if numel(obj.elbo) > 1
            obj.gain = (obj.elbo(end) - obj.elbo(end-1))/(max(obj.elbo)-min(obj.elbo));
        else
            gain = inf;
        end
        
        if obj.verbose > 0
            fprintf('%3d | ELBO = %10.6e | gain = %10.2e\n', i, elbo, obj.gain);
        end
        
        if i >= obj.iter_max
            break
        end
        if i >= obj.iter_min
            if abs(obj.gain) < obj.tolerance
                break
            end
        end
        i = i + 1;
        
    end
    
end