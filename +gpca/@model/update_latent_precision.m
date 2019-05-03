function obj = update_latent_precision(obj)

    if isfinite(obj.nA0)
    % ---------------------------------------------------------------------
    % Maximum likelihood (n0 == 0) or Variational posterior (n0 > 0)
    % ---------------------------------------------------------------------
        
        N = numel(obj.data);
        
        % ------------------
        % degrees of freedom
        % ------------------
        % > n = n0 + N
        obj.nA = obj.nA0 + N;
        
        % ------------------
        % maximum-likelihood
        % ------------------
        % > inv(ML[A]) = mean(Z*Z') + inv(Az)
        
        % ----------------
        % Variational mean
        % ----------------
        % > inv(E[A]) = (n0*inv(A0) + N*inv(ML[A]))/(n0 + N)
        obj.A = obj.ZZ + N * obj.iAz;
        if obj.nA0 > 0
            obj.A = obj.A + obj.nA0 * gpca.utils.invPD(obj.A0);
        end
        obj.A = obj.A / obj.nA;
        obj.A = gpca.utils.invPD(obj.A);
        
        % ----------------
        % Expected log det
        % ----------------
        obj.logA = gpca.utils.logdetPD(obj.A);
        if obj.nA0 > 0
            obj.logA = obj.logA ...
                        + gpca.utils.diGamma(0.5*obj.nA, obj.M) ...
                        - obj.M * log(obj.nA) ...
                        + obj.M * log(2);
        end
        
    else
    % ---------------------------------------------------------------------
    % Fixed value (n0 == inf)
    % ---------------------------------------------------------------------
        % Nothing to do
    end
    
end