function obj = apply_internal(obj)

    % ----------
    % Initialise
    % ----------
    obj.init_latent();
    obj.init_elbo_parts();
    obj.elbo_obs();
    obj.elbo_latent();
    
    % --------------
    % Compute latent
    % --------------
    obj.update_latent();
    obj.elbo_obs();
    obj.elbo_latent();
    
end