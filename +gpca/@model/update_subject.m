function subj_data = update_subject(obj,subj_data)

    x  = read(subj_data.x);
    mu = read(obj.mu);

    % -----------------------------------
    % Update latent [posterior precision]
    % -----------------------------------
    subj_data.Az = obj.A;
    
    % ------------------------------
    % Update latent [posterior mean]
    % ------------------------------
    M = size(Az,1);
    Lx = dot.solve(x-mu);
    subj_data.z = zeros(obj.M,1);
    for m=1:M
        Um   = read(obj.U,m);
        subj_data.z(m) = Um(:)'*Lx(:);
    end
    clear Lx
    subj_data.z  = pgca.utils.invPD(subj_data.Az)*subj_data.z;
    subj_data.zz = subj_data.z(:)*subj_data.z(:)' + obj.iA;
    
end