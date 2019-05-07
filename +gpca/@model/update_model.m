function obj = update_model(obj, do_plot)

    % ----
    % mean
    % ----
    obj.update_mean();
    obj.elbo_obs();
    obj.elbo_mean();
    
    if do_plot, obj.plot(); end
    
    % ----------------
    % latent precision
    % ----------------
    obj.update_latent_precision();
    obj.elbo_latent();
    obj.elbo_latent_precision();
    
    if do_plot, obj.plot(); end
    
    % --------
    % subspace
    % --------
    obj.update_subspace();
    obj.elbo_obs();
    obj.elbo_subspace();
    
    if do_plot, obj.plot(); end
    
    % -------------
    % orthogonalise
    % -------------
    obj.orthogonalise();
    obj.elbo_subspace();
    obj.elbo_latent();
    obj.elbo_latent_precision();
    
    if do_plot, obj.plot(); end
    
    % ------------------
    % residual precision
    % ------------------
    obj.update_residual_precision();
    obj.elbo_obs();
    obj.elbo_residual_precision();
    
    if do_plot, obj.plot(); end
    
end