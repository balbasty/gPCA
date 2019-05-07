function obj = orthogonalise(obj)

    N   = numel(obj.data);
    D   = prod(obj.lat);
    EUU = obj.ULU + D * obj.iAu;
    EZZ = obj.ZZ  + N * obj.iAz;
    
    % ---------------------------------------------------------------------
    % Orthogonalise
    [U, iU] = ortho_matrix(EZZ,EUU);

    EUU = iU' * EUU * iU;
    EZZ  = U  * EZZ  * U';
    
    % ---------------------------------------------------------------------
    % Rescale
    [Q, iQ] = gn_scale_U(EUU, EZZ, obj.A0, obj.nA0, N, D);
    Q  = Q  * U;
    iQ = iU * iQ;

    % ---------------------------------------------------------------------
    % Rotate subspace
    if numel(obj.lat) > 1
        slice_lat      = obj.lat;
        slice_lat(end) = 1;
        for z=1:obj.lat(end)
            Uz = gpca.format.read(obj.U, z, numel(obj.lat));
            Uz = reshape(Uz, [], obj.M) * iQ;
            Uz = reshape(Uz, [slice_lat obj.M]);
            obj.U = gpca.format.write(obj.U, Uz, z, numel(obj.lat));
        end
    else
        Uz = gpca.format.read(obj.U);
        Uz = Uz * iQ;
        obj.U = gpca.format.write(obj.U, Uz);
    end
    
    % ---------------------------------------------------------------------
    % Rotate sufficient statistics
    obj.ULU = iQ' * obj.ULU * iQ;
    obj.iAu = iQ' * obj.iAu * iQ;
    obj.Au  = Q   * obj.Au  * Q';
    obj.ZZ  = Q   * obj.ZZ  * Q';
    obj.iAz = Q   * obj.iAz * Q';
    obj.Az  = iQ' * obj.Az  * iQ;
    obj.Z   = Q   * obj.Z;
    
    % ---------------------------------------------------------------------
    % Rotate subjects
    Z  = obj.Z;
    Az = obj.Az;
    [data, obj.data] = deal(obj.data, []);
    parfor(n=1:numel(data), obj.parallel)
        data1    = data(n);
        data1.z  = Z(:,n);
        data1.zz = data1.z(:) * data1.z(:)';
        data1.Az = Az;
        data(n)  = data1;
    end
    obj.data = data; clear data
    
    % ---------------------------------------------------------------------
    % Update latent prior
    obj.update_latent_precision();
end