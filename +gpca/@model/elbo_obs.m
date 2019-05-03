function obj = elbo_obs(obj)

    N    = numel(obj.data);    % Number of observations
    D    = prod(obj.lat);      % Dimension of observed space
    logL = obj.dot.logdet();   % Log-determinant of known precision
    if ~isfinite(logL), logL = 0; end

    obj.lbX = - N * D * log(2*pi) ...
              + N * logL ...
              + N * D * obj.loglam ...
              - obj.lam * (obj.elbo_parts.trLS + N * obj.elbo_parts.varLM) ...
              - obj.lam * obj.elbo_parts.trULUZZ ...
              + 2 * obj.lam * obj.elbo_parts.trLUZX;
      
    obj.lbX = 0.5 * obj.lbX;
    
end