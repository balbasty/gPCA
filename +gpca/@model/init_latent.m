function obj = init_latent(obj)

    N = numel(obj.data);

    % ---------------------------------------------------
    % Generate random coordinates from prior distribution
    % ---------------------------------------------------
    Z  = zeros(obj.M,numel(obj.data));
    for n=1:numel(obj.data)
        Z(:,n)  = mvnrnd(zeros(obj.M, 1), gpca.utils.invPD(obj.A));
    end
    ZZ = Z*Z';
    Az = obj.A;
    
    % ------------------
    % Centre coordinates
    % ------------------
    z0 = sum(Z,2)/N;
    Z = bsxfun(@minus, Z, z0);
    ZZ = ZZ - N * (z0 * z0');
    
    
    % -------------
    % Orthogonalise
    % -------------
    [U,~,~] = svd(ZZ);
    Z  = U' * Z;
    ZZ = U' * ZZ * U;
    clear U
    
    % ---------------------------
    % Propagate to data structure
    % ---------------------------
    data     = obj.data;
    obj.data = [];
    parfor(n=1:numel(data), obj.parallel)
        data1    = data(n);
        data1.Az = Az;
        data1.z  = Z(:,n);
        data1.zz = data1.z(:)*data1.z(:)';
        data(n)  = data1;
    end
    obj.data = data;

    obj.Z   = Z;
    obj.ZZ  = ZZ;
    obj.Az  = Az;
    obj.iAz = gpca.utils.invPD(Az);
    obj.Z_iscentred = true;
end