function obj = init_latent(obj)

    Z  = zeros(obj.M,numel(obj.data));
    for n=1:numel(obj.data)
        Z(:,n)  = mvnrnd(zeros(obj.M, 1), gpca.utils.invPD(obj.A));
    end
    ZZ = Z*Z';
    Az = obj.A;
    
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
    
end