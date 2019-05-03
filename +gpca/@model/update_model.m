function obj = update_model(obj)

    % ----
    % mean
    % ----
    obj.update_mean();
    obj.elbo_obs();
    obj.elbo_mean();
    
    obj.plot();
    
    % ----------------
    % latent precision
    % ----------------
    obj.update_latent_precision();
    obj.elbo_latent();
    obj.elbo_latent_precision();
    
    obj.plot();
    
    % --------
    % subspace
    % --------
    obj.update_subspace();
    obj.elbo_obs();
    obj.elbo_subspace();
    
    obj.plot();
    
    % -------------
    % orthogonalise
    % -------------
    obj.orthogonalise();
    obj.elbo_latent();
    obj.elbo_subspace();
    
    obj.plot();
    
    % ------------------
    % residual precision
    % ------------------
    obj.update_residual_precision();
    obj.elbo_obs();
    obj.elbo_residual_precision();
    
    obj.plot();
    
end