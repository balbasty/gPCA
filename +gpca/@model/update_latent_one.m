function subj_data = update_latent_one(obj,subj_data)

    % -----------------------------------
    % Update latent [posterior precision]
    % -----------------------------------
    % Common to all subjects so we just copy the pre-computed value
    % > Az = A + lam * (U'*L*U + Au)
    subj_data.Az = obj.Az;
    
    % ------------------------------
    % Update latent [posterior mean]
    % ------------------------------
    % > E[z]    = lam * inv(Az) * U' * L * (x - mu)
    % > E[z*z'] = E[z]*E[z'] + inv(Az)
    M  = size(subj_data.Az,1);
    x  = gpca.format.read(subj_data.x);
    mu = gpca.format.read(obj.mu);
    % Compute L * (x - mu)
    Lx = obj.dot.solve(x - mu);
    % Compute U' * L * (x - mu)
    subj_data.z = zeros(obj.M,1);
    for m=1:M
        Um   = gpca.format.read(obj.U,m);
        subj_data.z(m) = Um(:)' * Lx(:);
    end
    clear Lx
    % Compute lam * inv(Az) * U' * L * (x - mu)
    subj_data.z  = obj.lam * obj.iAz * subj_data.z;
    % Compute E[z]*E[z'] + inv(Az)
    subj_data.zz = subj_data.z(:) * subj_data.z(:)';
    
end