function elbo_obs(obj)

    N    = numel(obj.data);    % Number of observations
    D    = prod(obj.lat);      % Dimension of observed space
    logL = obj.dot.logdet();   % Log-determinant of known precision
    if ~isfinite(logL), logL = 0; end

    lbX = - 0.5*N*D*log(2*pi) ...
          + 0.5*logL ...
          + 0.5*N*D*obj.loglam ...
          - 0.5*obj.lam*obj.trLS ...
          - 0.5*obj.lam*obj.trLM ...
          - 0.5*trace(obj.ULU*obj.ZZ);

    mu  = read(obj.mu);
    Lmu = dot.solve(mu);
    for m=1:obj.M
        LUm = read(obj.U, m);
        LUm = obj.dot.solve(LUm);
        
        data     = obj.data;
        obj.data = [];
        parfor(n=1:numel(data), obj.parallel)
            
            data1 = data(n);
            z     = read(data1.z);
            x     = read(data1.x);
            
            lbX = lbX - 0.5*obj.lam*z(m)*LUm(:)'*(mu(:)-x(:));
            
            if m==1
                lbX = lbX + obj.lam*Lmu(:)'*x(:);
            end
            
            x     = [];
            z     = [];
            data1 = [];
        end
        obj.data = data;
        
        clear LUm
        clear data
    end

    obj.lbX = lbX;
    
end