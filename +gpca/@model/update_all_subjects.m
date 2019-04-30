function update_all_subjects(obj)

    % ----------------------------------
    % precision (common across subjects)
    % ----------------------------------
    obj.A  = obj.lam * obj.ULU + obj.Az;
    obj.iA = gpca.utils.invPD(obj.A);

    % ----
    % mean
    % ----
    Z        = zeros(obj.M,numel(obj.data));
    ZZ       = zeros(obj.M);
    data     = obj.data;
    obj.data = [];
    
    parfor(n=1:numel(data), obj.parallel)
        
        data(n) = obj.update_subject(data(n));
        Z(:,n)  = data(n).z;
        ZZ      = ZZ + data(n).zz;
        
    end

    obj.data = data;
    obj.Z    = Z;
    obj.ZZ   = ZZ;
    
end
