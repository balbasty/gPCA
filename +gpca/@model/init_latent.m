function init_latent(obj)

    Z  = mvnrnd(zeros(obj.M, 1), gpca.utils.invPD(obj.Az));
    ZZ = Z*Z';
    A  = obj.Az;
    
    data     = obj.data;
    obj.data = [];
    parfor(n=1:numel(data), obj.parallel)
        data1    = data(n);
        data1.Az = A;
        data1.z  = Z(:,n);
        data1.zz = data1.z(:)*data1.z(:)' + data1.Az;
        data(n)  = data1;
    end
    obj.data = data;

    obj.Z  = Z;
    obj.ZZ = ZZ + numel(obj.data)*A;
    
end