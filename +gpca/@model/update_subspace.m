function update_subspace(obj)

    % ---------
    % precision
    % ---------
    obj.Au   = obj.lam * obj.ZZ;
    
    % ----
    % mean
    % ----
    ZiA      = obj.Z' * pgca.utils.invPD(obj.Au);
    mu       = read(obj.mu);
    ULU      = 0;
    data     = obj.data;
    obj.data = [];
    for m=1:obj.M
        Um       = 0;
        parfor(n=1:numel(data), obj.parallel)
            data1 = data(n);
            x     = read(data1.x);
            data1 = [];
            
            Um    = Um + (x - mu) * ZiA(n,m);
            
            x     = [];
            z     = [];
        end
        LUm   = obj.dot.solve(Um);
        ULU   = ULU + LUm(:)' * Um(:);
        clear LUM
        obj.U = write(obj.U, Um, m);
        clear UM
    end
    obj.data = data;
    obj.ULU = ULU + obj.Au;
    
end